function T = transCoeff(P,Q)
    %�O�_P���O�_Q�Ɏʂ��s���Ԃ�
    %P,Q��[[x y]; [x y]; [x y]]�̌`��
    A = [P [1; 1; 1]];
    coeffMat = [[A; zeros(3)] [zeros(3); A]];
    B = reshape(Q, [6,1]);
    coeffVec = coeffMat\B;
    T = [reshape(coeffVec, [3,2]).'; [0 0 1]].';
end
