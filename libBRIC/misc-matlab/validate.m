function [Ret] = validate(path, name, name_ref, name_base, name_voi, use_voi)
% Calculates validation statistics between generated and reference masks:
% - Confusion matrix, and from it
% - Accuracy, Sensitivity, Specificity, Jaccard, Dice, Kappa, Precision,
%   reject Precision
% Additionally, the total volume of the generated and reference masks
% are calculated.
% INPUTS: path - subject path
%         name - filename of the generated mask (relative to subject dir)
%         name_ref - filename of the reference mask (relative to subject dir)
%         name_base - filename of the base mask. This is needed to calculate
%                     the false positive rate, which is required for e.g.
%                     the sensitivity or kappa calculation. This mask should
%                     be bigger than the generated or reference masks. If
%                     empty this mask will be derived from the generated and
%                     reference masks.
%         name_voi - filename of the VOI masks to speed up processing by
%                    ignoring blank slices (see roi_init()).
%         use_voi - flag indicating whether name_voi should be used or not.
% OUTPUTS: Ret - Structure containing the validation results.
%

if use_voi
    S_voi = load_series(fullfile(path, name_voi), []);
    Roi = roi_init(S_voi);
	slices = roi_nifti_sliceno(Roi, []);   
else
	slices = [];
end

% New mask
SM = logical(load_series(fullfile(path, name), slices));
NII = load_series(fullfile(path, name), 0);
F = NII.hdr.dime.pixdim(2:4);

% Total gold standard mask
SM_ref = logical(load_series(fullfile(path, name_ref), slices));

if ~isempty(name_base)
	% Approx. of gold standard mask (always bigger than gold
    % standard, but smaller than ROI).
	SM_base = logical(load_series(fullfile(path, name_base), slices));
else
    SM_base = [];
end

Ret = validate_raw(SM, SM_ref, SM_base, F);
