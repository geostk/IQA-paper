function feat = brisque_feature(imdist)

%------------------------------------------------
% Feature Computation
%-------------------------------------------------
scalenum = 2;
window = fspecial('gaussian',7,7/6); %Fspecial函数用于创建预定义的滤波算子
window = window/sum(sum(window));

feat = [];
%tic  %在MATLAB里面可以使用tic和toc命令得到运行时间
for itr_scale = 1:scalenum
    
    mu            = filter2(window, imdist, 'same');
    mu_sq         = mu.*mu;
    sigma         = sqrt(abs(filter2(window, imdist.*imdist, 'same') - mu_sq));
    structdis     = (imdist-mu)./(sigma+1);
    
    
    [alpha overallstd]       = estimateggdparam(structdis(:));   % GGD
    feat                     = [feat alpha overallstd^2];
    
    
    shifts                   = [ 0 1;1 0 ; 1 1; -1 1]; % H,V,D1,D2
    
    for itr_shift =1:4
        
        shifted_structdis        = circshift(structdis,shifts(itr_shift,:));
        pair                     = structdis(:).*shifted_structdis(:);
        [alpha leftstd rightstd] = estimateaggdparam(pair);       %  AGGD
        const                    =(sqrt(gamma(1/alpha))/sqrt(gamma(3/alpha)));
        meanparam                =(rightstd-leftstd)*(gamma(2/alpha)/gamma(1/alpha))*const;
        feat                     =[feat alpha meanparam leftstd^2 rightstd^2];
        
    end
    
    
    imdist                   = imresize(imdist,0.5);
    
    
end
%toc