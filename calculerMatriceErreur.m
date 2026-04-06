function erreur = calculerMatriceErreur(imageReelle, imagePredite, varargin)
% CALCULERMATRICEERREUR Calculate error matrix between two images
%
%   erreur = calculerMatriceErreur(imageReelle, imagePredite)
%   erreur = calculerMatriceErreur(imageReelle, imagePredite, 'show', true)
%
%   Input:
%       imageReelle   - Original image (HxWx3 or HxW)
%       imagePredite  - Predicted image (same size as imageReelle)
%       'show'        - (Optional) true to display error image
%
%   Output:
%       erreur        - Absolute error matrix

    % Parse optional arguments
    p = inputParser;
    addRequired(p, 'imageReelle');
    addRequired(p, 'imagePredite');
    addParameter(p, 'show', false, @islogical);
    parse(p, imageReelle, imagePredite, varargin{:});

    show_image = p.Results.show;

    % Validate input images
    if ~isequal(size(imageReelle), size(imagePredite))
        error('Images must have the same size. Real: %s, Predicted: %s', ...
              mat2str(size(imageReelle)), mat2str(size(imagePredite)));
    end

    % Convert to double for calculation
    imageReelle = double(imageReelle);
    imagePredite = double(imagePredite);

    % Calculate absolute error
    erreur = abs(imageReelle - imagePredite);

    % Optional display
    if show_image
        figure('Name', 'Error Matrix', 'NumberTitle', 'off');
        if ndims(erreur) == 3
            % RGB error image
            imshow(uint8(erreur));
            title('RGB Prediction Error');
        else
            % Grayscale error image
            imshow(uint8(erreur));
            title('Grayscale Prediction Error');
        end
        colorbar;
    end
end

