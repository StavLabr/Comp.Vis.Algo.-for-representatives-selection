% Αυτή η συνάρτηση παίρνει έναν πίνακα DxN από N σημεία δεδομένων σε 
% D-διάστατο χώρο και επιστρέφει ένα NxN πίνακα συντελεστών της αραιής 
% αναπαράστασης κάθε σημείου δεδομένων με βάση τα υπόλοιπα σημεία.
% Y: Πίνακας δεδομένων DxN
% affine: true αν επιβάλλεται affine περιορισμός, false διαφορετικά
% thr1: κατώφλι διακοπής για το σφάλμα συντελεστών ||Z-C||
% thr2: κατώφλι διακοπής για το σφάλμα του ||Y-YZ||
% maxIter: μέγιστος αριθμός επαναλήψεων του ALM
% C2: NxN πίνακας αραιών συντελεστών

function [C2,Err] = almLasso_mat_func(Y,affine,alpha,q,thr,maxIter,verbose)

% Έλεγχος για τις παραμέτρους εισόδου και ρύθμιση των προεπιλεγμένων τιμών
if (nargin < 2)
    % Προεπιλεγμένοι υπόχωροι είναι γραμμικά συστήματα
    affine = false; 
end
if (nargin < 3)
    % Προεπιλεγμένη παράμετρος κανονικοποίησης
    alpha = 5;
end
if (nargin < 4)
    % Προεπιλεγμένη νόρμα στο πρόγραμμα βελτιστοποίησης L1/Lq
    q = 2;
end
if (nargin < 5)
    % Προεπιλεγμένο κατώφλι σφάλματος για διακοπή του ALM
    % Προεπιλεγμένο κατώφλι σφάλματος γραμμικού συστήματος για διακοπή του ALM
    thr = 1*10^-7; 
end
if (nargin < 6)
    % Προεπιλεγμένος μέγιστος αριθμός επαναλήψεων του ALM
    maxIter = 5000; 
end
if (nargin < 7)
    % Αναφορά των επαναλήψεων και των σφαλμάτων
    verbose = true; 
end

% Καθορισμός των τιμών alpha1 και alpha2 ανάλογα με το alpha
if (length(alpha) == 1)
    alpha1 = alpha(1);
    alpha2 = alpha(1);
elseif (length(alpha) == 2)
    alpha1 = alpha(1);
    alpha2 = alpha(2);
end
% Ρύθμιση κατωφλίων thr1 και thr2 ανάλογα με το thr
if (length(thr) == 1)
    thr1 = thr(1);
    thr2 = thr(1);
elseif (length(thr) == 2)
    thr1 = thr(1);
    thr2 = thr(2);
end

[D,N] = size(Y);

% Ρύθμιση παραμέτρων ποινής για τον ALM
mu1p = alpha1 * 1/computeLambda_mat(Y,affine);
mu2p = alpha2 * 1;

if (~affine)
    % Αρχικοποίηση
    mu1 = mu1p;
    mu2 = mu2p;
    P = Y'*Y;
    A = inv(mu1.*P+mu2.*eye(N));
    C1 = zeros(N,N);
    Lambda2 = zeros(N,N);
    err1 = 10*thr1; 
    i = 1;
    % Επαναλήψεις ALM
    while ( err1 > thr1 && i < maxIter )
        % Ενημέρωση του Z
        Z = A * (mu1.*P+mu2.*C1-Lambda2);
        % Ενημέρωση του C
        C2 = shrinkL1Lq(Z+Lambda2./mu2,1/mu2,q);
        % Ενημέρωση των πολλαπλασιαστών Lagrange
        Lambda2 = Lambda2 + mu2 .* (Z - C2);
        % Υπολογισμός σφαλμάτων
        err1 = errorCoef(Z,C2);
        %
        %mu1 = min(mu1*(1+10^-5),10^2*mu1p);
        %mu2 = min(mu2*(1+10^-5),10^2*mu2p);
        %
        C1 = C2;
        i = i + 1;
        % Αναφορά σφαλμάτων
        if (verbose && mod(i,100)==0)
            fprintf('Iteration %5.0f, ||Z - C|| = %2.5e, \n',i,err1);
        end
    end
    Err = err1;
    if (verbose)
        fprintf('Terminating ADMM at iteration %5.0f, \n ||Z - C|| = %2.5e, \n',i,err1);
    end
else
    % Αρχικοποίηση
    mu1 = mu1p;
    mu2 = mu2p;
    P = Y'*Y;
    A = inv(mu1.*P+mu2.*eye(N)+mu2.*ones(N,N));
    C1 = zeros(N,N);
    Lambda2 = zeros(N,N);
    lambda3 = zeros(1,N);
    err1 = 10*thr1; err2 = 10*thr2;
    i = 1;
    % Επαναλήψεις ALM
    while ( (err1 > thr1 || err2 > thr1) && i < maxIter )
        % Ενημέρωση του Z
        Z = A * (mu1.*P+mu2.*(C1-Lambda2./mu2)+mu2.*ones(N,N)+repmat(lambda3,N,1));
        % Ενημέρωση του C
        C2 = shrinkL1Lq(Z+Lambda2./mu2,1/mu2,q);  
        % Ενημέρωση των πολλαπλασιαστών Lagrange
        Lambda2 = Lambda2 + mu2 .* (Z - C2);
        lambda3 = lambda3 + mu2 .* (ones(1,N) - sum(Z,1));
        % Υπολογισμός σφαλμάτων
        err1 = errorCoef(Z,C2);
        err2 = errorCoef(sum(Z,1),ones(1,N));
        %
        %mu1 = min(mu1*(1+10^-5),10^2*mu1p);
        %mu2 = min(mu2*(1+10^-5),10^2*mu2p);
        %
        C1 = C2;
        i = i + 1;
        % Αναφορά σφαλμάτων
        if (verbose && mod(i,100)==0)
            fprintf('Iteration %5.0f, ||Z - C|| = %2.5e, ||1 - C^T 1|| = %2.5e, \n',i,err1,err2);
        end
    end
    Err = [err1;err2];
    if (verbose)
        fprintf('Terminating ADMM at iteration %5.0f, \n ||Z - C|| = %2.5e, ||1 - C^T 1|| = %2.5e. \n',i,err1,err2);
    end
end
