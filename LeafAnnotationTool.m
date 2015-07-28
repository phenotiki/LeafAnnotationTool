function varargout = LeafAnnotationTool(varargin)
% LEAFANNOTATIONTOOL MATLAB code for LeafAnnotationTool.fig
%
% Author:  Mario Valerio Giuffrida
% Contact: valerio.giuffrida@imtlucca.it
% Version: 1.0
% Date:    26/06/2015
%
% Copyright (C) 2015 Pattern Recognition and Image Analysis (PRIAn) Unit,
% IMT Institute for Advanced Studies, Lucca, Italy.
% All rights reserved.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LeafAnnotationTool_OpeningFcn, ...
                   'gui_OutputFcn',  @LeafAnnotationTool_OutputFcn, ...
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


% --- Executes just before LeafAnnotationTool is made visible.
function LeafAnnotationTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LeafAnnotationTool (see VARARGIN)

% Choose default command line output for LeafAnnotationTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setStatusToButtons(handles,'off');
% UIWAIT makes LeafAnnotationTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global LastPath;
global LabelCount;

if (isempty(LastPath) || ~ischar(LastPath)) LastPath = pwd; end;

resetLabels(handles);
addpath('graphAnalysisToolbox-1.0');

% --- Outputs from this function are returned to the command line.
function varargout = LeafAnnotationTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global LastPath;
[fname, path] = uigetfile({'*.png';'*.jpg';'*.bmp'},'Open an Image File',LastPath);
LastPath = path;

openImage(handles,path,fname);

global Annotations;
Annotations=cell(0,2);
resetLabels(handles);

function openImage(handles,path,fname)
global RawImage;
global WorkingImage;

RawImage = imread(fullfile(path,fname));
WorkingImage = RawImage;

setStatusToButtons(handles,'on');

updateWorkingImage(handles);

function updateWorkingImage(handles)
global WorkingImage;
global Annotations;

imshow(WorkingImage,'Parent',handles.axes1);
hold(handles.axes1,'on');
hold(handles.axes1,'off');


% --- Executes on button press in btnMask.
function btnMask_Callback(hObject, eventdata, handles)
% hObject    handle to btnMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Annotations;

btnCancel_Callback(handles.btnCancel,[],handles);

if (isempty(Annotations))
    global LastPath;
    [fname, path] = uigetfile({'*.png';'*.jpg';'*.bmp'},'Open an Image File',LastPath);
    LastPath = path;

    global Mask;
    global WorkingImage;
    global RawImage;

    Mask = imread(fullfile(path,fname));
    WorkingImage = RawImage .* repmat(Mask,1,1,3);

    updateWorkingImage(handles);
end

% --- Executes on button press in rdnDot.
function rdnDot_Callback(hObject, eventdata, handles)
% hObject    handle to rdnDot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdnDot

global Annotations;

h=impoint(handles.axes1);
Annotations{end+1,1} = h;
l=increaseCurrentLabel(handles);
updateLastScribble(l);

% --- Executes on button press in rdnLine.
function rdnLine_Callback(hObject, eventdata, handles)
% hObject    handle to rdnLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdnLine
global WorkingImage;
global Annotations;

h=imline(handles.axes1);
Annotations{end+1,1} = h;
l=increaseCurrentLabel(handles);
updateLastScribble(l);



% --- Executes on button press in rdnFreehand.
function rdnFreehand_Callback(hObject, eventdata, handles)
% hObject    handle to rdnFreehand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rdnFreehand
global Annotations;

h=imfreehand(handles.axes1);
h.setClosed(false)
Annotations{end+1,1} = h;

l=increaseCurrentLabel(handles);
updateLastScribble(l);

function setStatusToButtons(hObject,status)
set(hObject.btnMask,'Enable',status)
set(hObject.rdnDot,'Enable',status)
set(hObject.rdnLine,'Enable',status)
set(hObject.rdnFreehand,'Enable',status)
set(hObject.btnLoadAnnotations,'Enable',status);


% --- Executes on button press in btnSegment.
function btnSegment_Callback(hObject, eventdata, handles)
% hObject    handle to btnSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Annotations;
global Mask;
global WorkingImage;
global Result;

coords = [];
labels = [];

for i=1:size(Annotations,1)
    if (~strcmp(class(Annotations{i}),'imline'))
        p = Annotations{i}.getPosition();
        
        coords = [coords;p];
        labels = [labels; repmat(Annotations{i,2},size(p,1),1)];
    else
        lst = Annotations{i}.getPosition();
        
        int_x = lst(1,1):0.1:lst(2,1);
        int_y = lst(1,2):0.1:lst(2,2);
        
        coords = [coords; int_x' int_y'];
        labels = [labels; repmat(Annotations{i,2},length(int_x),1)];
    end
end

coords = round(coords);

idx = find(~Mask);
[I, J] = ind2sub(size(Mask), idx);
coords = cat(1,coords,[J, I]);
labels = [labels;zeros(length(idx),1)];

beta = get(handles.sldBeta,'Value');
[mask, probabilities] = grady(WorkingImage,Mask,coords,labels,beta);

Result = uint8(mask);
updateResults(handles);
set(handles.btnSave,'Enable','on');

function i = getVisualizationMode(handles)
switch get(handles.rdnLabels,'Value')
    case 1
        i = 1;
    otherwise
        i = 2;
end


function updateResults(handles)
global Result;
global WorkingImage;

if (getVisualizationMode(handles)==1)
    cmap = getColorMap();

    imshow(Result,cmap,'Parent',handles.axes2);
else
    [imgMasks,segOutline,imgMarkup]=segoutput(im2double(WorkingImage),im2double(Result));
    imshow(imgMarkup,[],'Parent',handles.axes2);
    
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if ( strcmp(eventdata.Modifier,'control') || strcmp(eventdata.Modifier,'command') )
    if ((eventdata.Key == 'z') || (eventdata.Key == 'Z'))
        global Annotations;
        if (~isempty(Annotations))
            Annotations{end,1}.delete;
            Annotations = Annotations(1:end-1,:);
        end
    end
end


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Annotations;

if (~isempty(Annotations))
    btn = questdlg('Do you want to cancel all the annotation''s hint?','title','Are you sure?');

    if (strcmp(btn,'Yes'))
        for i=1:size(Annotations,1)
            Annotations{i,1}.delete;
        end

        Annotations = cell(0,2);
    end
end
resetLabels(handles);

% --- Executes on button press in btnLoadAnnotations.
function btnLoadAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoadAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LastPath;
global Annotations;

[fname, path] = uigetfile({'*.png';'*.jpg';'*.bmp'},'Open an Image File',LastPath);
LastPath = path;

I = imread(fullfile(path,fname));

if (size(I,3)==1)
    %[y x] = find(I);
    
    CC = bwconncomp(I);
    
    for k = 1:length(CC.PixelIdxList)
        idx = CC.PixelIdxList{k};
        [y x] = ind2sub(size(I),idx);
        
        l=increaseCurrentLabel(handles);
        
        for i=1:length(x)
            h = impoint(handles.axes1,x(i),y(i));
            Annotations{end+1,1} = h;
            
            updateLastScribble(l);
        end
    end
else
    warndlg('Invalid image file.');
end

function r = getIndexedColor(i)
colors = getColorMap(); colors = colors(2:end,:);

t =mod(i-1,size(colors,1))+1;
r = colors( t ,:);



function txtLabel_Callback(hObject, eventdata, handles)
% hObject    handle to txtLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtLabel as text
%        str2double(get(hObject,'String')) returns contents of txtLabel as a double

updateLastScribble( str2num(get(handles.txtLabel,'string')));

function updateLastScribble (l)
global Annotations;
Annotations{end,2} = l;

Annotations{end,1}.setColor( getIndexedColor(l) );

% --- Executes during object creation, after setting all properties.
function txtLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function l = getCurrentLabel(handles)
l = str2num(  get(handles.txtLabel,'string')  );

function l = increaseCurrentLabel(handles)
global LabelCount;
LabelCount = LabelCount+1;

l = LabelCount;

set(handles.txtLabel,'string',num2str(l));


% --- Executes on slider movement.
function sldBeta_Callback(hObject, eventdata, handles)
% hObject    handle to sldBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.txtBeta,'String',num2str( get(handles.sldBeta,'Value'), '%.1f' ));


% --- Executes during object creation, after setting all properties.
function sldBeta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function txtBeta_Callback(hObject, eventdata, handles)
% hObject    handle to txtBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtBeta as text
%        str2double(get(hObject,'String')) returns contents of txtBeta as a double
set(handles.sldBeta,'Value',str2double( get(handles.txtBeta,'String') ));

% --- Executes during object creation, after setting all properties.
function txtBeta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Result;
global LastPath;

map = getColorMap();

if (numel(Result) > 0)
    [fname, path] = uiputfile({'*.png'},'Save Segmentation',LastPath);
    
    if (~isempty(fname))
        imwrite(uint8(Result),map,fullfile(path,fname));
    end
end


% --- Executes when selected object is changed in uipanel9.
function uipanel9_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel9 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

updateResults(handles);


function resetLabels(handles)
global LabelCount;

LabelCount = 0;
set(handles.txtLabel,'String','1');
