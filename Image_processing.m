clear;
clc;

% Καθορισμός της διαδρομής προς τον φάκελο που περιέχει τις εικόνες
imageFolder = '';

% Λήψη της λίστας με όλα τα αρχεία εικόνων στον φάκελο
imageFiles = dir(fullfile(imageFolder, '*.jpg')); % Αλλάξτε το '*.jpg' στην κατάλληλη μορφή αρχείου, αν χρειάζεται

% Αρχικοποίηση ενός κενού πίνακα για την αποθήκευση των ασπρόμαυρων διανυσμάτων εικόνων για τον SMRS
grayFrameMatrix = [];
% Αρχικοποίηση ενός πίνακα κελιών για αποθήκευση των αρχικών ασπρόμαυρων εικόνων
grayscaleImages = {};
% Αρχικοποίηση του μετρητή εικόνων
imageNumber = 1;

% Βρόχος για κάθε εικόνα στον φάκελο
for i = 1:length(imageFiles)
    % Δημιουργία της πλήρους διαδρομής προς το αρχείο εικόνας
    imageFile = fullfile(imageFolder, imageFiles(i).name);
    
    % Ανάγνωση της εικόνας (θεωρώντας ότι είναι ήδη ασπρόμαυρη[grayscale])
    grayImage = imread(imageFile);
    
    % Αποθήκευση της αρχικής εικόνας
    grayscaleImages{imageNumber} = grayImage;
    
    % Μετατροπή της ασπρόμαυρης εικόνας σε single precision
    singleGrayImage = im2single(grayImage);
    
    % Μετατροπή της εικόνας σε μονοδιάστατο διάνυσμα
    imageVector = singleGrayImage(:);
    
    % Προσθήκη του διανύσματος εικόνας ως νέα στήλη στον πίνακα grayFrameMatrix
    grayFrameMatrix = [grayFrameMatrix, imageVector];
    
    imageNumber = imageNumber + 1;
end

% Εισαγωγή του πίνακα δεδομένων
Y = grayFrameMatrix;

% Εισαγωγή της παραμέτρου κανονικοποίησης
alpha = 2; % τυπικά το alpha είναι ανάμεσα στο [2,20]

% Αν επιθυμούμε να μειώσουμε τη διάσταση των δεδομένων μέσω PCA, 
% εισάγουμε τη διάσταση r, αλλιώς θέτουμε r = 0 για χρήση των δεδομένων χωρίς προβολές
r = 0;

% Αναφορά πληροφοριών σχετικά με τις επαναλήψεις
verbose = true;

% Εξασφαλίζουμε ότι η συνάρτηση SMRS είναι διαθέσιμη και εκτελούμε τον SMRS
if exist('smrs', 'file') == 2
    [repInd, C] = smrs(Y, alpha, r, verbose);
else
    error('SMRS function is not available. Please ensure it is in your MATLAB path.');
end

% Για ανακατασκευή και προβολή των αντιπροσωπευτικών εικόνων:
% Υποθέτουμε ότι όλες οι εικόνες έχουν το ίδιο μέγεθος
originalImageSize = size(grayscaleImages{1}); % Χρήση του μεγέθους της πρώτης εικόνας
numRepImages = length(repInd); % Αριθμός αντιπροσωπευτικών εικόνων

% Αρχικοποίηση ενός 3D πίνακα για αποθήκευση των αντιπροσωπευτικών ασπρόμαυρων εικόνων
repImages = zeros([originalImageSize(1), originalImageSize(2), numRepImages], 'single');

% Αποθήκευση των αντιπροσωπευτικών εικόνων
for i = 1:numRepImages
    index = repInd(i);
    imageVector = Y(:, index); % Εξαγωγή της αντίστοιχης στήλης
    grayImage = reshape(imageVector, originalImageSize(1:2)); % Ανασύνθεση σε δισδιάστατη εικόνα
    
    % Αποθήκευση της αντιπροσωπευτικής εικόνας επιπέδων του γκρι
    repImages(:, :, i) = grayImage;
end

% Προβολή όλων των αντιπροσωπευτικών εικόνων
figure;
montage(repImages, 'Size', [ceil(sqrt(numRepImages)), ceil(sqrt(numRepImages))]);
title('Representative Images');