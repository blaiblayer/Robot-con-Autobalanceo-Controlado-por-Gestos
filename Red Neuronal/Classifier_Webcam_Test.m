clc; close all; clear all;
%% Open webcam and load neural network
cam = webcam;
load poncenet;

%% Define Processing Box Dimensions + Position
x=0;
y=0;
height = 500;
width = 500;
bboxes=[x y height width];

%%
global SerCOM

% Cierra los puertos que se hayan podido quedar abiertos
Puertos_Activos=instrfind; % Lee los puertos activos
if isempty(Puertos_Activos)==0 % Comprueba si hay puertos activos
    fclose(Puertos_Activos); % Cierra los puertos activos
    delete(Puertos_Activos) % Borra la variable Puertos_Activos
    clear Puertos_Activos % Destruye la variable Puertos_Activos
end

SerCOM = serial('COM4'); % Se crea el objeto serial asociado al COM que corresponda
SerCOM.BaudRate=9600; % Se configura el objeto serial a 9600 baudios
SerCOM.DataBits=8; % Se configura el nº de bits a 8
SerCOM.Parity='none'; % Se configura el objeto serial sin bit de paridad
SerCOM.StopBits=1; % Se configura el objeto serial con 1 STOP bit
SerCOM.FlowControl='none'; % Se configura el objeto serial sin control de flujo
fopen(SerCOM); % Se abre el puerto COM asociado al objeto serial


%% Define Duty for Motor 1 + 2 for each Class
% Class 1
Dato_Forward_M1 = 173; 
Dato_Forward_M2 = 173;

% Class 2
Dato_Left_M1 = 128; 
Dato_Left_M2 = 173;

% Class 3
Dato_Right_M1 = 173; 
Dato_Right_M2 = 0;

% Class 4
Dato_Backwards_M1 = 45; 
Dato_Backwards_M2 = 45;

% Class 5
Dato_Paro = 128; % igual para ambos motores

while true
    webcamsnapshot = cam.snapshot;% Capture frames
    IFaces = insertObjectAnnotation(webcamsnapshot,'rectangle',bboxes,'Processing Area');% Set processing area  
    webcamsnapshot_crop = imcrop(webcamsnapshot,bboxes);
    webcamsnapshot_crop = imresize(webcamsnapshot_crop,[227 227]);% Resize capture images
    label = classify(poncenet,webcamsnapshot_crop);% Set class from captured image
    imshow(IFaces);

    if label == '1_finger' % Forward
     title('Fingers: 1');
     fwrite(SerCOM,Dato_Paro); 
     fwrite(SerCOM,Dato_Paro);
     pause(0.5);
        while label == '1_finger'
             title('Fingers: 1');
     fwrite(SerCOM,Dato_Forward_M1); 
     fwrite(SerCOM,Dato_Forward_M2);
webcamsnapshot = cam.snapshot;% Capture frames
    IFaces = insertObjectAnnotation(webcamsnapshot,'rectangle',bboxes,'Processing Area');% Set processing area  
    webcamsnapshot_crop = imcrop(webcamsnapshot,bboxes);
    webcamsnapshot_crop = imresize(webcamsnapshot_crop,[227 227]);% Resize capture images
    label = classify(poncenet,webcamsnapshot_crop);% Set class from captured image
    imshow(IFaces);
        end
     
    elseif label == '2_finger' % Turn Left
     title('Fingers: 2');
     fwrite(SerCOM,Dato_Paro); 
     fwrite(SerCOM,Dato_Paro);
     pause(0.5);
        while label == '2_finger'
             title('Fingers: 2');
     fwrite(SerCOM,Dato_Left_M1); 
     fwrite(SerCOM,Dato_Left_M2); 
     webcamsnapshot = cam.snapshot;% Capture frames
    IFaces = insertObjectAnnotation(webcamsnapshot,'rectangle',bboxes,'Processing Area');% Set processing area  
    webcamsnapshot_crop = imcrop(webcamsnapshot,bboxes);
    webcamsnapshot_crop = imresize(webcamsnapshot_crop,[227 227]);% Resize capture images
    label = classify(poncenet,webcamsnapshot_crop);% Set class from captured image
    imshow(IFaces);
        end
     
    elseif label == '3_finger' %Turn Right
     title('Fingers: 3'); 
     fwrite(SerCOM,Dato_Paro); 
     fwrite(SerCOM,Dato_Paro);
      pause(0.5);
        while label == '3_finger'
             title('Fingers: 3');
     fwrite(SerCOM,Dato_Right_M1); 
     fwrite(SerCOM,Dato_Right_M2);
     webcamsnapshot = cam.snapshot;% Capture frames
    IFaces = insertObjectAnnotation(webcamsnapshot,'rectangle',bboxes,'Processing Area');% Set processing area  
    webcamsnapshot_crop = imcrop(webcamsnapshot,bboxes);
    webcamsnapshot_crop = imresize(webcamsnapshot_crop,[227 227]);% Resize capture images
    label = classify(poncenet,webcamsnapshot_crop);% Set class from captured image
    imshow(IFaces);
        end
     
    elseif label == '4_finger' % Backwards
        title('Fingers: 4');
     fwrite(SerCOM,Dato_Paro); 
     fwrite(SerCOM,Dato_Paro);
      pause(0.5);
        while label == '4_finger'
     title('Fingers: 4');
     fwrite(SerCOM,Dato_Backwards_M1); 
     fwrite(SerCOM,Dato_Backwards_M2);
     webcamsnapshot = cam.snapshot;% Capture frames
    IFaces = insertObjectAnnotation(webcamsnapshot,'rectangle',bboxes,'Processing Area');% Set processing area  
    webcamsnapshot_crop = imcrop(webcamsnapshot,bboxes);
    webcamsnapshot_crop = imresize(webcamsnapshot_crop,[227 227]);% Resize capture images
    label = classify(poncenet,webcamsnapshot_crop);% Set class from captured image
    imshow(IFaces);
        end
     
    elseif label == 'background' % Nada
     title('Detecting gesture...');
     fwrite(SerCOM,Dato_Paro); 
     fwrite(SerCOM,Dato_Paro);
     
     elseif label == 'cara_blai' % Nada
     title('Blayer detectado');
     fwrite(SerCOM,Dato_Paro); 
     fwrite(SerCOM,Dato_Paro);
     
     elseif label == 'cara_paco' % Nada
     title('Paquito estás muy blanco');
     fwrite(SerCOM,Dato_Paro); 
     fwrite(SerCOM,Dato_Paro);
     
     elseif label == 'cara_ponce' % Nada
     title('Buena tula bro');
     fwrite(SerCOM,Dato_Paro); 
     fwrite(SerCOM,Dato_Paro);
    end
    drawnow;
end
