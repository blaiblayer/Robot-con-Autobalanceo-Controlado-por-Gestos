function varargout = PWM(varargin)
% PWM MATLAB code for PWM.fig
%      PWM, by itself, creates a new PWM or raises the existing
%      singleton*.
%
%      H = PWM returns the handle to a new PWM or the handle to
%      the existing singleton*.
%
%      PWM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PWM.M with the given input arguments.
%
%      PWM('Property','Value',...) creates a new PWM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PWM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PWM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PWM

% Last Modified by GUIDE v2.5 22-Nov-2020 02:58:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PWM_OpeningFcn, ...
                   'gui_OutputFcn',  @PWM_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before PWM is made visible.
function PWM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PWM (see VARARGIN)
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

% Choose default command line output for PWM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PWM wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PWM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sldPWM_Callback(hObject, eventdata, handles)
% hObject    handle to sldPWM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SerCOM

handles.lblPWM.String=num2str(hObject.Value); % Se actualiza el valor del slider en la etiqueta
Dato=hObject.Value; % Se lee el nuevo valor del slider
if (handles.optCW.Value==1) % Si el sentido de giro es CW
    Dato=Dato+128;          % se pone el bit más significativo a '1' 
end
Dato2=handles.sldPWM2.Value; % cambiarrr!!!!!!!
if (handles.optCW2.Value==1) % Si el sentido de giro es CW
    Dato2=Dato2+128;          % se pone el bit más significativo a '1' 
end
Dato
Dato2
if (handles.cmdONOFF.Value==1) % Si el toggle button está accionado
    fwrite(SerCOM,Dato); % Se envía el dato
    fwrite(SerCOM,Dato2); % Se envía el dato 2
end


% --- Executes during object creation, after setting all properties.
function sldPWM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldPWM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SerCOM

fclose(SerCOM); % Se cierra el puerto COM
clear SerCOM; % Se limpia de la memoria el objeto SerCOM

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in optCW.
function optCW_Callback(hObject, eventdata, handles)
% hObject    handle to optCW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optCW
global SerCOM

Dato=handles.sldPWM.Value; % Si se selecciona CW se envía
Dato=Dato+128;             % el valor del slider con el 
                           % bit más significativo a '1'

Dato2=handles.sldPWM2.Value;
if (handles.optCW2.Value==1)
    Dato2=Dato2+128;
end

if (handles.cmdONOFF.Value==1)
    fwrite(SerCOM,Dato);
    fwrite(SerCOM,Dato2);       
end

% --- Executes on button press in optCCW.
function optCCW_Callback(hObject, eventdata, handles)
% hObject    handle to optCCW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optCCW
global SerCOM

Dato=handles.sldPWM.Value; % Si se selecciona CCW se envía el valor del
                             % slider con el bit más significativo a '0'
Dato2=handles.sldPWM2.Value;
if (handles.optCW2.Value==1)
    Dato2=Dato2+128;
end

if (handles.cmdONOFF.Value==1)
    fwrite(SerCOM,Dato);
    fwrite(SerCOM,Dato2);       
end


% --- Executes on slider movement.
function sldPWM2_Callback(hObject, eventdata, handles)
% hObject    handle to sldPWM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SerCOM

handles.lblPWM2.String=num2str(hObject.Value); % Se actualiza el valor del slider en la etiqueta
Dato2=hObject.Value; % Se lee el nuevo valor del slider
if (handles.optCW2.Value==1) % Si el sentido de giro es CW
    Dato2=Dato2+128;          % se pone el bit más significativo a '1' 
end
Dato=handles.sldPWM.Value;
if (handles.optCW.Value==1) % Si el sentido de giro es CW
    Dato=Dato+128;          % se pone el bit más significativo a '1'
end
Dato
Dato2
if (handles.cmdONOFF.Value==1)
    fwrite(SerCOM,Dato); % Se envía el dato
    fwrite(SerCOM,Dato2); % Se envía el dato2
end

% --- Executes during object creation, after setting all properties.
function sldPWM2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldPWM2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in optCW2.
function optCW2_Callback(hObject, eventdata, handles)
% hObject    handle to optCW2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optCW2
global SerCOM

Dato=handles.sldPWM.Value;
if (handles.optCW.Value==1) 
    Dato=Dato+128;
end

Dato2=handles.sldPWM2.Value; % Si se selecciona CW se envía
Dato2=Dato2+128;             % el valor del slider con el 
                             % bit más significativo a '1'   
if (handles.cmdONOFF.Value==1)
    fwrite(SerCOM,Dato);
    fwrite(SerCOM,Dato2);       
end


% --- Executes on button press in optCCW2.
function optCCW2_Callback(hObject, eventdata, handles)
% hObject    handle to optCCW2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optCCW2
global SerCOM

Dato=handles.sldPWM.Value;
if (handles.optCW.Value==1)
    Dato=Dato+128;
end
Dato2=handles.sldPWM2.Value; % Si se selecciona CCW se envía el valor del
                             % slider con el bit más significativo a '0'
if (handles.cmdONOFF.Value==1)
    fwrite(SerCOM,Dato);
    fwrite(SerCOM,Dato2);       
end

% --- Executes on button press in cmdONOFF.
function cmdONOFF_Callback(hObject, eventdata, handles)
% hObject    handle to cmdONOFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cmdONOFF
global SerCOM

if hObject.Value==1
    hObject.String='TURN OFF';
    handles.cmdONOFF.BackgroundColor=[1 0 0];
    
    Dato=handles.sldPWM.Value;
    if (handles.optCW.Value==1)
        Dato=Dato+128;
    end
    Dato2=handles.sldPWM2.Value;
    if (handles.optCW2.Value==1)
        Dato2=Dato2+128;
    end
    fwrite(SerCOM,Dato);
    fwrite(SerCOM,Dato2);
else
    hObject.String='TURN ON';
    handles.cmdONOFF.BackgroundColor=[1 1 1];
    
    Datoparo=128; % Cero CW
    Datoparo2=128;
    fwrite(SerCOM,Datoparo);
    fwrite(SerCOM,Datoparo2);
end
