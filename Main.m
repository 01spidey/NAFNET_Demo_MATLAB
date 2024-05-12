clc;

[FileName,PathName] = uigetfile('*.jpg;*.png;*.bmp','Pick an MRI Image');
if isequal(FileName,0)||isequal(PathName,0)
    warndlg('User Pressed Cancel');
else
    P = imread([PathName,FileName]);
    P = imresize(P,[200,200]);

    input_img = P;
    
    figure(1)
    imshow(P);
    title('Input Image');
    
    gr=rgb2gray(P);
    
    
    F1 = medfilt2(gr);
    F2 = stdfilt(gr);           
    F3 = wiener2(gr,[5 5]);
    
    se = strel('disk',5);
    F4 = imopen(gr,se);
    
    F5=imclose(gr,se);
    
    se1 = strel('disk',15);
    back = imopen(gr,se1);
    en1= gr - back;
    %en2 = imadjust(en1);
    en2 = imadjust(gr);

    gaussian = imnoise(P,'gaussian', 0.2);
    gaussian = imresize(gaussian,[200,200]);
    gaussian_gr=rgb2gray(gaussian);

    imwrite(gaussian, fullfile('Noise_image', 'noise_image.jpg'));
    disp('Noise image saved!!');

    imwrite(input_img, fullfile('Clean_image', 'clean_image.jpg'))
    disp('Clean Image Saved!!')

    % Storing the en2 image
    save_folder = 'Enhanced_image';

    % Create the folder if it doesn't exist
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end

    % Construct the full path for saving the enhanced image
    save_path = fullfile(save_folder, 'enhanced_image.jpg');
    
    % Save the enhanced image
    imwrite(en2, save_path);
    
    % Display a message indicating that the image has been saved
    disp(['Enhanced image saved at: ' save_path]);

    % Now, the file has been saved to 'Enhanced_image' folder.
    % Now, we've to run the 'bm3d_denoising_script.py' file.

    % Calling the Python script with the specified interpreter
    python_script = 'NAFNET/basicsr/demo.py';
    options_file = 'NAFNET/options/test/SIDD/NAFNet-width64.yml';
    %input_path = 'Enhanced_image/enhanced_image.jpg';
    input_path = 'Noise_image/noise_image.jpg';
    output_path = 'Denoised_image/denoised_img.jpg';
    
    system_command = ['python ', python_script, ' -opt ', options_file, ' --input_path ', input_path, ' --output_path ', output_path];
    system(system_command);
    
    % Display a message indicating that the Python script has been executed
    disp('Python script executed successfully');

    denoised_image = imread('Denoised_image/denoised_img.jpg');

    denoised_image = imresize(denoised_image,[200,200]);
    denoised_gr=rgb2gray(denoised_image);
    denoised_image = imadjust(denoised_gr);
    imwrite(denoised_image, fullfile(save_folder, 'enhanced_image_imadjust.jpg'));
    disp("Imadjust image saved") 

    figure
    title('Noise vs Denoised Image')

    subplot(1,2,1);
    imshow(gaussian);
    title('Noisy Image');

    subplot(1,2,2);
    imshow(denoised_image)
    title('NAFNet Denoised Image')
    
end