function varargout = LeafAnnotationTool(varargin)
%LEAFANNOTATIONTOOL MATLAB code for LeafAnnotationTool.fig
%   Part of the leaf annotation tool described in [1].
%
%   [1] M. Minervini, M. V. Giuffrida, S. A. Tsaftaris, "An interactive tool for semi-automated leaf annotation,"
%       in Proceedings of the Computer Vision Problems in Plant Phenotyping (CVPPP) Workshop, pp. 6.1–6.13.
%       BMVA Press, Sep. 2015.
%
%   Author(s): Massimo Minervini, Mario Valerio Giuffrida
%   Contact:   massimo.minervini@imtlucca.it
%   Version:   1.1
%   Date:      19/10/2015
%
%   Copyright (C) 2015 Pattern Recognition and Image Analysis (PRIAn) Unit,
%   IMT Institute for Advanced Studies, Lucca, Italy.
%   All rights reserved.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton', gui_Singleton, ...
    'gui_OpeningFcn', @LeafAnnotationTool_OpeningFcn, ...
    'gui_OutputFcn', @LeafAnnotationTool_OutputFcn, ...
    'gui_LayoutFcn', [] , ...
    'gui_Callback', []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


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

if (isempty(LastPath) || ~ischar(LastPath)) LastPath = pwd; end;

resetLabels(handles);
addpath('graphAnalysisToolbox-1.0');
end


% --- Outputs from this function are returned to the command line.
function varargout = LeafAnnotationTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LastPath;
[fname, path] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';'*.*','All Files'},'Open an Image File',LastPath);
if isequal(fname,0)
    return
else
    LastPath = path;
end
openImage(handles,path,fname);
global Annotations;
Annotations = cell(0,2);
resetLabels(handles);
global Result;
Result = [];
colorbar(handles.axes2,'off')
delete(allchild(handles.axes2)) %cla(handles.axes2)
set(handles.btnSave,'Enable','off');
set(handles.rdnContours,'Enable','off');
set(handles.rdnLabels,'Enable','off');
end


function openImage(handles,path,fname)
global RawImage;
global WorkingImage;
RawImage = imread(fullfile(path,fname));
WorkingImage = RawImage;
setStatusToButtons(handles,'on');
updateWorkingImage(handles);
end


function updateWorkingImage(handles)
global WorkingImage;
imshow(WorkingImage,'Parent',handles.axes1);
% hold(handles.axes1,'on');
% hold(handles.axes1,'off');
end


function setStatusToButtons(hObject,status)
set(hObject.btnMask,'Enable',status)
set(hObject.rdnDot,'Enable',status)
set(hObject.rdnLine,'Enable',status)
set(hObject.rdnFreehand,'Enable',status)
set(hObject.btnLoadAnnotations,'Enable',status);
set(hObject.btnSegment,'Enable',status);
set(hObject.btnSave,'Enable',status);
set(hObject.rdnContours,'Enable',status);
set(hObject.rdnLabels,'Enable',status);
end


% --- Executes on button press in btnMask.
function btnMask_Callback(hObject, eventdata, handles)
% hObject    handle to btnMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Annotations;
btnCancel_Callback(handles.btnCancel,[],handles);
if ~isempty(Annotations)
    return
end
global LastPath;
[fname, path] = uigetfile({'*.png';'*.bmp'},'Open an Image File',LastPath);
if isequal(fname,0)
    return
else
    LastPath = path;
end
global Mask;
global WorkingImage;
global RawImage;
Mask = imread(fullfile(path,fname));
WorkingImage = RawImage.*repmat(Mask,1,1,3);
updateWorkingImage(handles);
increaseCurrentLabel(handles);
end


% --- Executes on button press in rdnDot.
function rdnDot_Callback(hObject, eventdata, handles)
% hObject    handle to rdnDot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Annotations;
h = impoint(handles.axes1);
Annotations{end+1,1} = h;
updateLastScribble(getCurrentLabel());
increaseCurrentLabel(handles);
end


% --- Executes on button press in rdnLine.
function rdnLine_Callback(hObject, eventdata, handles)
% hObject    handle to rdnLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Annotations;
h = imline(handles.axes1);
Annotations{end+1,1} = h;
updateLastScribble(getCurrentLabel());
increaseCurrentLabel(handles);
end


% --- Executes on button press in rdnFreehand.
function rdnFreehand_Callback(hObject, eventdata, handles)
% hObject    handle to rdnFreehand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Annotations;
h = imfreehand(handles.axes1,'Closed',false);
%h.setClosed(false)
Annotations{end+1,1} = h;
updateLastScribble(getCurrentLabel());
increaseCurrentLabel(handles);
end


% --- Executes on button press in btnSegment.
function btnSegment_Callback(hObject, eventdata, handles)
% hObject    handle to btnSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Annotations;
global Mask;
global WorkingImage;
global Result;
tStart = tic;
seeds = [];
labels = [];
for i = 1:size(Annotations,1)
    if ~isa(Annotations{i},'imline')
        p = Annotations{i}.getPosition();
        seeds = [seeds; p];
        labels = [labels; repmat(Annotations{i,2},size(p,1),1)];
    else
        lst = Annotations{i}.getPosition();
        A = lst(1,:);
        B = lst(2,:);
        coordinates = [];
        for t = 0:.05:1
            x = A(1)+(B(1)-A(1))*t;
            y = A(2)+(B(2)-A(2))*t;
            coordinates = [coordinates; x y];
        end
        seeds = [seeds; coordinates];
        labels = [labels; repmat(Annotations{i,2},size(coordinates,1),1)];
    end
end
seeds = round(seeds);
if ~isempty(Mask)
    idx = find(~Mask);
    [I, J] = ind2sub(size(Mask),idx);
    seeds = cat(1,seeds,[J, I]);
    labels = [labels; zeros(length(idx),1)];
end
beta = get(handles.sldBeta,'Value');
[M, ~] = grady(WorkingImage,Mask,seeds,labels,beta);
Result = uint8(M);
set(handles.textElapsedTime,'String',['Elapsed time (s): ' num2str(toc(tStart),'%.1f')]);
updateResults(handles);
set(handles.btnSave,'Enable','on');
set(handles.rdnContours,'Enable','on');
set(handles.rdnLabels,'Enable','on');
end


function m = getVisualizationMode(handles)
switch get(handles.rdnLabels,'Value')
    case 1
        m = 1;
    otherwise
        m = 2;
end
end


function updateResults(handles)
global Result;
global WorkingImage;
if getVisualizationMode(handles) == 1
    cmap = getColorMap();
    imshow(Result,cmap,'Parent',handles.axes2);
    pos = get(handles.axes2,'position');
    colorbar(handles.axes2,...
        'Ticks',0:max(Result(:)),...
        'TickDirection','out',...
        'TickLabels',['BG',cellfun(@num2str,num2cell(1:max(Result(:))),'uniformoutput',0)])
    set(handles.axes2,'position',[pos(1) pos(2) pos(3) pos(4)]);
else
    [~,~,imgMarkup] = segoutput(im2double(WorkingImage),im2double(Result));
    imshow(imgMarkup,[],'Parent',handles.axes2);
end
end


function resetLabels(handles)
global LabelCount;
global Mask
if isempty(Mask)
    LabelCount = 0;
    set(handles.txtLabel,'String','0');
else
    LabelCount = 1;
    set(handles.txtLabel,'String','1');
end
end


function l = getCurrentLabel()
global LabelCount;
l = LabelCount;
end

function l = increaseCurrentLabel(handles)
global LabelCount;
LabelCount = LabelCount+1;
l = LabelCount;
set(handles.txtLabel,'string',num2str(l,'%d'));
end


function updateLastScribble(l)
global Annotations;
Annotations{end,2} = l;
Annotations{end,1}.setColor(getIndexedColor(l));
end


function rgb = getIndexedColor(i)
if i == 0
    rgb = [0,0,0];
else
    cmap = getColorMap();
    cmap = cmap(2:end,:);
    rgb = cmap(mod(i-1,size(cmap,1))+1,:);
end
end

% Return customized color map (based on Tango color palette).
function cmap = getColorMap()
cmap = [0,0,0; % background
    252,233,79;
    114,159,207;
    239,41,41;
    173,127,168;
    138,226,52;
    233,185,110;
    252,175,62;
    211,215,207;
    196,160,0;
    32,74,135;
    164,0,0;
    92,53,102;
    78,154,6;
    143,89,2;
    206,92,0;
    136,138,133;
    237,212,0;
    52,101,164;
    204,0,0;
    117,80,123;
    115,210,22;
    193,125,17;
    245,121,0;
    186,189,182;
    136,138,133;
    85,87,83;
    46,52,54;
    238,238,236]/255;
end


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global Annotations;
if ( strcmp(eventdata.Modifier,'control') || strcmp(eventdata.Modifier,'command') )
    if ((eventdata.Key == 'z') || (eventdata.Key == 'Z'))
        if ~isempty(Annotations)
            Annotations{end,1}.delete;
            Annotations = Annotations(1:end-1,:);
        end
    end
end
end


% --- Executes on button press in btnCancel.
function btnCancel_Callback(hObject, eventdata, handles)
% hObject    handle to btnCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Annotations;
if ~isempty(Annotations)
    btn = questdlg('Are you sure you want to delete all annotations?','Confirm delete');
    if (strcmp(btn,'Yes'))
        for i=1:size(Annotations,1)
            Annotations{i,1}.delete;
        end
        Annotations = cell(0,2);
        resetLabels(handles);
    end
end
end


% --- Executes on button press in btnLoadAnnotations.
function btnLoadAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoadAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LastPath;
global Annotations;
[fname, path] = uigetfile({'*.png';'*.jpg';'*.bmp'},'Open an Image File',LastPath);
if isequal(fname,0)
    return
else
    LastPath = path;
end
I = imread(fullfile(path,fname));
if size(I,3)==1
    %[y x] = find(I);
    CC = bwconncomp(I);
    for k = 1:length(CC.PixelIdxList)
        idx = CC.PixelIdxList{k};
        [y, x] = ind2sub(size(I),idx);
        l = increaseCurrentLabel(handles);
        for i=1:length(x)
            h = impoint(handles.axes1,x(i),y(i));
            Annotations{end+1,1} = h;
            updateLastScribble(l);
        end
    end
else
    warndlg('Invalid image file.');
end
end


function txtLabel_Callback(hObject, eventdata, handles)
% hObject    handle to txtLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtLabel as text
%        str2double(get(hObject,'String')) returns contents of txtLabel as a double

updateLastScribble(str2double(get(handles.txtLabel,'string')));
end


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
end


% --- Executes on slider movement.
function sldBeta_Callback(hObject, eventdata, handles)
% hObject    handle to sldBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.txtBeta,'String',num2str(round(get(handles.sldBeta,'Value')),'%d'));
end


% --- Executes during object creation, after setting all properties.
function sldBeta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


function txtBeta_Callback(hObject, eventdata, handles)
% hObject    handle to txtBeta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtBeta as text
%        str2double(get(hObject,'String')) returns contents of txtBeta as a double
input = str2double(get(handles.txtBeta,'String'));
if isnan(input)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return
elseif input < get(handles.sldBeta,'Min') || input > get(handles.sldBeta,'Max')
    errordlg(['Beta must be in the range ' num2str(get(handles.sldBeta,'Min'),'%d') '..' num2str(get(handles.sldBeta,'Max'),'%d')],'Invalid Input','modal')
    uicontrol(hObject)
    return
else
    set(handles.sldBeta,'Value',input);
end
end


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
end


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Result;
global LastPath;
cmap = getColorMap();
if ~isempty(Result)
    [fname,path] = uiputfile('*.png','Save Segmentation',LastPath);
    if ~isequal(fname,0) && ~isequal(path,0)
        if (~isempty(fname))
            imwrite(uint8(Result),cmap,fullfile(path,fname),'png');
        end
    end
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
end
