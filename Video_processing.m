clear;
clc;

% Καθορισμός της διαδρομής προς το αρχείο βίντεο
videoFile = '-';

% Δημιουργία του αντικειμένου VideoReader
vidObj = VideoReader(videoFile);

% Αρχικοποίηση ενός κενού πίνακα για αποθήκευση των ασπρόμαυρων καρέ για τον SMRS
grayFrameMatrix = [];
% Αρχικοποίηση ενός πίνακα κελιών για αποθήκευση των αρχικών RGB καρέ
rgbFrames = {};
% Βρόχος επεξεργασίας καρέ του βίντεο
frameNumber = 1;
while hasFrame(vidObj)
    frame = readFrame(vidObj);

    % Αποθήκευση του αρχικού RGB καρέ
    rgbFrames{frameNumber} = frame;
    
    % Μετατροπή του καρέ σε single precision
    singleFrame = im2single(frame);
    
    % Μετατροπή του καρέ σε ασπρόμαυρο
    grayFrame = rgb2gray(singleFrame);
    
    % Επίπεδωση του ασπρόμαυρου καρέ σε μονοδιάστατο διάνυσμα
    frameVector = grayFrame(:);
    
    % Προσθήκη του διανύσματος ως νέα στήλη στον πίνακα grayFrameMatrix
    grayFrameMatrix = [grayFrameMatrix, frameVector];
    
    frameNumber = frameNumber + 1;
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

% Για ανακατασκευή και προβολή των αντιπροσωπευτικών καρέ:
originalFrameSize = [vidObj.Height, vidObj.Width]; % Αρχικό μέγεθος καρέ
numRepFrames = length(repInd); % Αριθμός αντιπροσωπευτικών καρέ

% Αρχικοποίηση ενός 4D πίνακα για αποθήκευση των αντιπροσωπευτικών RGB καρέ
repFrames = zeros([originalFrameSize, 3, numRepFrames], 'single');

% Μετατροπή των αντιπροσωπευτικών ασπρόμαυρων καρέ πίσω σε RGB και αποθήκευσή τους
for i = 1:numRepFrames
    index = repInd(i);
    frameVector = Y(:, index); % Εξαγωγή της αντίστοιχης στήλης
    grayFrame = reshape(frameVector, originalFrameSize); % Ανασύνθεση σε δισδιάστατο καρέ
    rgbFrame = repmat(grayFrame, [1, 1, 3]); % Μετατροπή από ασπρόμαυρη σε RGB
    
    % Αποθήκευση του αντιπροσωπευτικού καρέ
    repFrames(:, :, :, i) = rgbFrame;
end

% Προβολή όλων των αντιπροσωπευτικών καρέ
figure;
montage(repFrames, 'Size', [ceil(sqrt(numRepFrames)), ceil(sqrt(numRepFrames))]);
title('Representative Frames');