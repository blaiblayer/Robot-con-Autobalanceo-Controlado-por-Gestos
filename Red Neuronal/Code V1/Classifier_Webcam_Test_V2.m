clc; close all; clear all;
%% Open webcam and load neural network
w = webcam;
load alexnet;

%% Define Processing Box 1 + 2
x1=0;
y1=0;
height1 = 250;
width1 = 250;
bboxes1=[x1 y1 height1 width1];

x2=400;
y2=0;
height2 = 250;
width2 = 250;
bboxes2=[x2 y2 height2 width2];

position = [bboxes1; bboxes2];
label = ('Processing Area');

while true
    webcamsnapshot = w.snapshot;% Capture frames
    Process_area= insertObjectAnnotation(webcamsnapshot,'rectangle',position,label);% Set processing area
    webcamsnapshot_crop1 = imcrop(webcamsnapshot,bboxes1);
    webcamsnapshot_crop2 = imcrop(webcamsnapshot,bboxes2);
    webcamsnapshot_crop1 = imresize(webcamsnapshot_crop1,[227 227]);% Resize capture images
    webcamsnapshot_crop2 = imresize(webcamsnapshot_crop2,[227 227]);% Resize capture images
    label1 = classify(alexnet,webcamsnapshot_crop1);% Set class from captured image
    label2 = classify(alexnet,webcamsnapshot_crop2);% Set class from captured image
    imshow(Process_area);

    if label1 == '1_finger' % Forward
     title('Fingers: 1');
    elseif label1 == '2_finger' % Turn Left
     title('Fingers: 2');
    elseif label1 == '3_finger' %Turn Right
     title('Fingers: 3'); 
    elseif label1 == '4_finger' % Backwards
     title('Fingers: 4');
    elseif label1 == 'background' % Backwards
     title('Background');
    end
    drawnow;
end