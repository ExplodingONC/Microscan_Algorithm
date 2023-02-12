function [img_out] = imtranslate_general(img_in, trans, varargin)
%IMTRANSLATE_GENERAL 此处显示有关此函数的摘要
%   此处显示详细说明
    inf_mask = isinf(img_in);
    nan_mask = isnan(img_in);
    img_in(inf_mask|nan_mask) = 0;
    img_out = imtranslate(img_in, trans, varargin{:});
    inf_mask = imtranslate(inf_mask, trans, varargin{:});
    nan_mask = imtranslate(nan_mask, trans, varargin{:});
    img_out(inf_mask) = Inf;
    img_out(nan_mask) = NaN;
end

