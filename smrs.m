% Αυτή η συνάρτηση λαμβάνει τον πίνακα δεδομένων και την τιμή της παραμέτρου
% κανονικοποίησης για να υπολογίσει τον αραιό πίνακα γραμμών που υποδεικνύει τους αντιπροσώπους.
% Y: Πίνακας δεδομένων DxN με N σημεία δεδομένων σε D-διάστατο χώρο
% alpha: Παράμετρος κανονικοποίησης, συνήθως στην περιοχή [2,50]
function [repInd,C] = smrs(Y,alpha,r,verbose)

if (nargin < 2)
    alpha = 5;% Χρησιμοποιείται προεπιλεγμένη τιμή για την παράμετρο κανονικοποίησης
end
if (nargin < 3)
    r = 0;% r: προβάλλει τα δεδομένα σε χώρο r-διαστάσεων αν χρειάζεται ή 0 για τα αρχικά δεδομένα
end
if (nargin < 4)
    verbose = true;% verbose: true για να εμφανίζονται πληροφορίες σχετικά με τις επαναλήψεις
end
% Ορισμός παραμέτρων που χρησιμοποιούνται για τον αλγόριθμο
q = 2;% Κανονικοποίηση l2-norm
regParam = [alpha alpha];% Παράμετροι κανονικοποίησης
affine = true;
thr = 1 * 10^-7;% Όριο για σύγκλιση
maxIter = 1000;% Μέγιστος αριθμός επαναλήψεων
thrS = 0.99;% Όριο για επιλογή αντιπροσώπων
thrP = 0.95;% Όριο για αφαίρεση περιττών αντιπροσώπων
N = size(Y,2);
% Κανονικοποίηση των δεδομένων: αφαιρείται ο μέσος όρος από κάθε σημείο δεδομένων
Y = Y - repmat(mean(Y,2),1,N);
% Αν έχει δοθεί διάσταση r, πραγματοποιείται SVD για μείωση διαστάσεων
if (r >= 1)
    [~,S,V] = svd(Y,0);
    r = min(r,size(V,1));
    Y = S(1:r,1:r) * V(:,1:r)';
end
% Εκτέλεση της συνάρτησης almLasso για την εξαγωγή του πίνακα συντελεστών C
C = almLasso_mat_func(Y,affine,regParam,q,thr,maxIter,verbose);
% Εύρεση των αντιπροσώπων χρησιμοποιώντας τα αποτελέσματα του πίνακα C
sInd = findRep(C,thrS,q);
% Αφαίρεση περιττών αντιπροσώπων
repInd = rmRep(sInd,Y,thrP);