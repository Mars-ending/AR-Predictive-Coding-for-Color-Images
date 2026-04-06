function H = calc_entropie(image)
% CALC_ENTROPIE Calculate entropy of an image
%
%   H = calc_entropie(image)
%
%   Input:
%       image - Grayscale or RGB image (HxW or HxWx3)
%
%   Output:
%       H     - Entropy in bits per pixel
%
%   Note: For RGB images, automatic conversion to grayscale

    % Validate input
    if ~isnumeric(image)
        error('Image must be a numeric matrix');
    end

    % Convert RGB to grayscale if needed
    if ndims(image) == 3
        if size(image, 3) == 3
            % RGB image
            image = rgb2gray(uint8(image));
        else
            error('3D images must have 3 channels (RGB)');
        end
    end

    % Ensure image is in valid range
    image = double(image);
    if min(image(:)) < 0 || max(image(:)) > 255
        % Normalize to [0, 255] if outside range
        image = 255 * (image - min(image(:))) / (max(image(:)) - min(image(:)));
    end

    % Convert to vector
    image_vector = image(:);

    % Calculate normalized histogram
    nbNiveaux = 256;
    try
        h = histcounts(image_vector, 0:nbNiveaux, 'Normalization', 'probability');
    catch
        % Fallback for older MATLAB versions
        [counts, ~] = hist(image_vector, 0:255);
        h = counts / sum(counts);
    end

    % Remove zeros to avoid log2(0)
    h = h(h > 0);

    % Check if image is constant (zero entropy case)
    if length(h) <= 1
        H = 0;
        return;
    end

    % Calculate entropy in bits
    H = -sum(h .* log2(h));

    % Ensure non-negative result
    H = max(0, H);
end
