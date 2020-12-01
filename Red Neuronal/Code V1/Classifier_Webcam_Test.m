clc; close all; clear all;
%% Open webcam and load neural network
w = webcam;

%% Define Processing Box Dimensions + Position
x=0;
y=0;
height = 300;
width = 300;
bboxes=[x y height width];

%% Define Duty for Motor 1 + 2 for each Class
% Class 1
Dato_Forward_M1 = 173; 
Dato_Forward_M2 = 173;

% Class 2
Dato_Left_M1 = 128; 
Dato_Left_M2 = 173;

% Class 3
Dato_Right_M1 = 45; 
Dato_Right_M2 = 0;

% Class 4
Dato_Backwards_M1 = 45; 
Dato_Backwards_M2 = 45;

load alexnet;

while true
    webcamsnapshot = w.snapshot;% Capture frames
    IFaces = insertObjectAnnotation(webcamsnapshot,'rectangle',bboxes,'Processing Area');% Set processing area  
    webcamsnapshot_crop = imcrop(webcamsnapshot,bboxes);
    webcamsnapshot_crop = imresize(webcamsnapshot_crop,[227 227]);% Resize capture images
    label = classify(alexnet,webcamsnapshot_crop);% Set class from captured image
    imshow(IFaces);

    if label == '1_finger' % Forward
     title('Fingers: 1');
%      fwrite(SerCOM,Dato_Forward_M1); 
%      fwrite(SerCOM,Dato_Forward_M2);
     
    elseif label == '2_finger' % Turn Left
     title('Fingers: 2');
%      fwrite(SerCOM,Dato_Left_M1); 
%      fwrite(SerCOM,Dato_Left_M2); 
     
    elseif label == '3_finger' %Turn Right
     title('Fingers: 3'); 
%      fwrite(SerCOM,Dato_Right_M1); 
%      fwrite(SerCOM,Dato_Right_M2); 
     
    elseif label == '4_finger' % Backwards
     title('Fingers: 4');
%      fwrite(SerCOM,Dato_Backwards_M1); 
%      fwrite(SerCOM,Dato_Backwards_M2);
    end
    drawnow;
end

clear w
