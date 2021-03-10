function T = transCoeff(P,Q)
    %三点Pを三点Qに写す行列を返す
    %P,Qは[[x y]; [x y]; [x y]]の形式
    A = [P [1; 1; 1]];
    coeffMat = [[A; zeros(3)] [zeros(3); A]];
    B = reshape(Q, [6,1]);
    coeffVec = coeffMat\B;
    T = [reshape(coeffVec, [3,2]).'; [0 0 1]].';
end
