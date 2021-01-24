function [outstruct] = mydicominfo(filename)
%[info] = mydicominfo(filename)
%Simple DICOM parser as an example in the course Medical Image Analysis
%FMAN30, Centre of Mathematical Sciences, Engineering Faculty, Lund University.
%
%Change and add to the function taglist to add more DICOM tags to read
%
%The file is heavily inspired from the function fastdicominfo written by
%Einar Heiberg for the Segment project (http://segment.heiberg.se).
%
%To get rid of debug print, change in function debugprint, (or showknowntag
%and showunknowntag).
%
%See also MYDICOMREAD.
%
%Einar Heiberg 2014

if nargin==0
  error('Expected at least a filename.');
end;

[tags2find,grouplist,elementlist] = taglist; %Call function taglist that defines the DICOM dictionary (see below).

%--- Prepare the output struct
outstruct = [];
for loop=1:length(tags2find)
  outstruct = setfield(outstruct,tags2find(loop).name,tags2find(loop).default); %#ok<SFLD>
end;

%--- Open the file
fid=fopen(filename,'r','l');
if fid == -1
  error('Could not open the file');
end;

%Check size of file
f = dir(filename);
numbytesinfile = f.bytes;

%--- Check header ofset
%Some file has a 128 byte offset
fseek(fid,128,'bof');

[stri,numread] = fread(fid,4,'uchar'); %Read 4 chars
if numread~=4
  %Could not get bytes must be error => exiting.  
  outstruct.StartOfPixelData = 0;  
  fclose(fid);
  return;
end;

if any(stri - [68;73;67;77]~=0) %DICM
  %warning('Not a DICOM file?'); 
  offset = 0;
else
  offset = 128+4;
end

%Intialize position
curpos = uint32(offset);

%--- Start reading tags
foundtags = zeros(1,length(tags2find));
tagsread = 0;

fseek(fid,double(offset),'bof');

%--- Find if explicit/implicit mode
temp = fread(fid,2,'*uint16'); %#ok<NASGU> %group & element num
vr = fread(fid,2,'uint8=>char');
if ((vr(1)>64)&&(vr(1)<91))&&((vr(2)>64)&&(vr(2)<91))
  explicitmode = true; %first tag contained vr  
  debugprint('Explicit mode');  
else
  explicitmode = false; %first tag did not contain vr  
  debugprint('Implicit mode');  
end;

fseek(fid,-2-2-2,'cof'); %-group-tag-vr
    
while ...
    not(feof(fid)) && .... %end if end of file
    (sum(foundtags) < length(tags2find)) && ... %not all tags found
    (tagsread<1e4) && ... %end if read very many tags...
    (curpos<numbytesinfile)
  
  %--- Read tag header
  [groupnumber,elementnumber,~,datasize,curpos,explicitmode] = readtagheader(fid,curpos,explicitmode);
  
  %--- If last groupnumber is be empty ignore to, avoid trouble
  if not(isempty(groupnumber))
      
        
    %Check if wanted tag
    if not(feof(fid))
      
      %Look the tag up in the dictionary           
      pos = find((groupnumber==grouplist)&(elementnumber==elementlist));
      
      if (~isempty(pos))
        parsedtag = false; %Is set to true when parsed tag
        
        showknowntag(tags2find,pos(1),vr,datasize);        
        
        %Check if TransferSyntaxUid telling explict or implicit Dicom mode          
        if (pos(1) == 1) %we have assumed that the first element in the dicom list is transfersyntaxuid
          
          %Here we parse the tag transfer syntax
          data = readtagdata(fid,datasize,tags2find(pos(1)).type);
          data = data((double(data)>47)&(double(data)<58)|(data=='.')); %remove blanks
          switch data
            case '1.2.840.10008.1.2.1' %Dicom explicit vr little endian
              debugprint('Explicit VR little endian');
              explicitmode = true;
            case '1.2.840.10008.1.2'   %Dicom implicit vr little endian
              debugprint('Implicit VR little endian');
              explicitmode = false;
            case '1.2.840.10008.1.2.2' %Dicom explicit vr big endian
              fclose(fid);
              error('Explicit vr big endian files currently not supported.');
            case {'1.2.840.10008.1.2.4.57',... %JPEG Lossless
                '1.2.840.10008.1.2.4.70',... %JPEG Lossless First Order
                '1.2.840.10008.1.2.5',... %RLE Lossless
                '1.2.840.10008.1.2.4.90',... %JPEG 2000 (lossless)
                '1.2.840.10008.1.2.4.50',... %JPEG Baseline
                '1.2.840.10008.1.2.4.51',... %JPEG Extended
                '1.2.840.10008.1.2.4.91'} %JPEG 2000 (lossy)
              fclose(fid);
              error('Compressed files currently not supported.');              
            otherwise 
              warning(sprintf('Could not interpret TransferSyntaxUID value %s',data)) %#ok<WNTAG,SPWRN>
          end; %switch clause
          parsedtag = true;
        end; %TransferSyntax tag             
      
        %Check if pixeldata
        if (pos(1)==2) %we have assumed that the second element in the dicom dictionary is pixeldata
          startofpixeldata = ftell(fid); %curpos; %was -datasize;
          outstruct.StartOfPixelData = startofpixeldata;
          parsedtag = true;
        end;
        
        %ordinary tag to be read
        if ~parsedtag
          data = readtagdata(fid,datasize,tags2find(pos(1)).type);
          if isnan(data)
            data = tags2find(pos(1)).default;
          end;
          
          %Store data
          outstruct.(tags2find(pos(1)).name) = data;
          foundtags(pos(1)) = 1;
        end;
        
      else
        % one gets here if the tag could not be found in the list of tags.
        % image data or unwanted tag or parsed tag

        %Display the tag
        showunknowntag(groupnumber,elementnumber,vr,datasize);
        
        fseek(fid,double(datasize),'cof');
      end; %found tag
    end;
  end; %not empty groupnumber
    
  tagsread = tagsread+1;
  
end; %While clause

%Close file
fclose(fid);

%-------------------------------------------
function [t,grouplist,elementlist] = taglist
%-------------------------------------------
%This is the list of DICOM tags, i.e dictionary

%This function needs to be complemented with suitable tags.
%Keep the two first in the above order as this is assumed in the main function

t= [];
t(1).name = 'TransferSyntaxUID';    t(1).groupnumber = '0002'; t(1).elementnumber = '0010'; t(1).type = 'char';   t(1).default = '1.2.840.10008.1.2.1.';
t(2).name = 'StartOfPixelData';     t(2).groupnumber = '7fe0'; t(2).elementnumber = '0010'; t(2).type = 'uint16'; t(2).default = [];
t(3).name = 'BitsAllocated';        t(3).groupnumber = '0028'; t(3).elementnumber = '0100'; t(3).type = 'uint16'; t(3).default=0;
t(4).name = 'RescaleSlope';         t(4).groupnumber = '0028'; t(4).elementnumber = '1053'; t(4).type = 'char';   t(4).default='1';

%%% Add more tags here that you will require %%%
t(5).name = 'RescaleIntercept';     t(5).groupnumber = '0028'; t(5).elementnumber = '1052'; t(5).type = 'char';   t(5).default='0';
t(6).name = 'SliceThickness';     t(6).groupnumber = '0018'; t(6).elementnumber = '0050'; t(6).type = 'char';   t(6).default='1';
t(7).name = 'SpacingBetweenSlices';     t(7).groupnumber = '0018'; t(7).elementnumber = '0088'; t(7).type = 'char';   t(7).default='0';
t(8).name = 'Rows';     t(8).groupnumber = '0028'; t(8).elementnumber = '0010'; t(8).type = 'uint16';   t(8).default=[];
t(9).name = 'Columns';     t(9).groupnumber = '0028'; t(9).elementnumber = '0011'; t(9).type = 'uint16';   t(9).default=[];
t(10).name = 'PixelSpacing';     t(10).groupnumber = '0028'; t(10).elementnumber = '0030'; t(10).type = 'char';   t(10).default=1;
%t(11).name = 'BitsStored';     t(11).groupnumber = '0028'; t(11).elementnumber = '0101'; t(11).type = 'uint16';   t(11).default=[];
%t(12).name = 'PixelData';     t(12).groupnumber = '7ef0'; t(12).elementnumber = '0010'; t(12).type = 'uint32';   t(12).default=[];

%%%

%--- Prepare the input struct, convert from hex
grouplist = hex2dec(cat(1,t(:).groupnumber));
elementlist = hex2dec(cat(1,t(:).elementnumber));

%------------------------------------------------------------------------------------------------------------
function [groupnumber,elementnumber,vr,datasize,curpos,explicitmode] = readtagheader(fid,curpos,explicitmode) 
%------------------------------------------------------------------------------------------------------------
%Read a tag from a dicom file

if explicitmode
  %--- Explicit mode
  groupnumber = fread(fid,1,'*uint16'); %Read groupnumber
  if isempty(groupnumber)
    groupnumber = [];
    elementnumber = [];
    vr = '';
    datasize = uint32(0);
    %eof
    return;
  end;
  elementnumber = fread(fid,1,'*uint16'); %Read elementnumber
  
  if groupnumber>65533
    %FFFE,E0DD, delimiting tag has no VR
    %FFFF
    vr = '..';
    datasize = fread(fid,1,'*uint32'); 
    if datasize>4e9 %must be ffff ie unknown value
      datasize=0;
    end;
    curpos = curpos+4+4+datasize;
  else
    %Check VR
    vr = fread(fid,2,'uchar=>char')';
    if ((vr(1)>64)&&(vr(1)<91))&&((vr(2)>64)&&(vr(2)<91))
      switch vr
        case {'OB','OW','OF','SQ','UT','UN'}
          fread(fid,2,'*char'); % skip two bytes
          datasize = fread(fid,1,'*uint32'); %4
          if datasize>4e9 %must be ffff ie unknown value
            datasize=0;
          end;
          curpos = curpos+4+2+2+4+datasize; %tagnumber+vr+2+4+data
        otherwise
          datasize = fread(fid,1,'uint16=>uint32'); %2
          if datasize>4e9 %must be ffff ie unknown value
            datasize=0;
          end;
          curpos = curpos+4+2+2+datasize;   %tagnumber+vr+2+data
      end
    
    else
      %no valid vr
      vr = '--';
      fseek(fid,-2,'cof');
      datasize = fread(fid,1,'*uint32'); %2
    end;
  end;
end;

if not(explicitmode)  
  %--- Implicit mode
  groupnumber = fread(fid,1,'*uint16'); %Read group number
  elementnumber = fread(fid,1,'*uint16'); %Read element number

  if groupnumber<8
    %For low group numbers check if still explicitmode anyway
    vr = fread(fid,2,'uchar=>char')';
    if ((vr(1)>64)&&(vr(1)<91))&&((vr(2)>64)&&(vr(2)<91))
      %explicit mode anyway
      switch vr
        case {'OB','OW','OF','SQ','UT','UN'}
          fseek(fid,2,'cof');
          datasize = fread(fid,1,'*uint32'); %4
          curpos = curpos+4+2+2+4+datasize; %tagnumber+vr+2+4+data
        otherwise
          datasize = fread(fid,1,'uint16=>uint32'); %2
          curpos = curpos+4+2+2+datasize;   %tagnumber+vr+2+data
      end
      return;
    else
      fseek(fid,-2,'cof'); %go back since we read vr to check
    end;
  end;
  
  %Implicit mode if managed to get here
  vr = '--';
  datasize = fread(fid,1,'*uint32'); %Read data size

  if datasize>4e9 %must be ffff ie unknown value
    datasize = 0;
  end; 

  %Increment file pointer
  curpos = curpos+4+4+datasize;
end;

%------------------------------------------------------
function showunknowntag(groupnumber,elementnumber,vr,datasize)
%------------------------------------------------------
debugprint('Unknown: (%04x,%04x) %s %d',groupnumber,elementnumber,vr,datasize);

%-----------------------------------------------
function showknowntag(tags2find,pos,vr,datasize)
%-----------------------------------------------
debugprint('%s: (%s,%s) VR=%s Length=%d',tags2find(pos).name,tags2find(pos).groupnumber,tags2find(pos).elementnumber,char(vr)',datasize);

%------------------------------------------------
function out = readtagdata(fid,datasize,datatype)
%------------------------------------------------
%Read data and convert
if datasize==0
  out = [];
  return;
end;

switch datatype
  case 'char'
    out = fread(fid,double(datasize),'uchar=>char')';
  case 'num'
    out = fread(fid,double(datasize),'uchar=>char')';
    out(out=='\')=' ';
    [numout,ok] = str2num(out); %#ok<ST2NM>
    if ok
      out = numout;
    else
      out = NaN;
    end;
  case 'uint8'
    out = fread(fid,double(datasize),datatype)';
  case 'uint16'
    out = fread(fid,double(datasize)/2,datatype)';
  case {'single','float'}
    out = fread(fid,double(datasize)/4,'float')';
  otherwise
    fclose(fid);
    error(sprintf('Unknown data format %s.',datatype)); %#ok<SPERR>
end;

%------------------------------
function debugprint(s,varargin)
%------------------------------

if false %change to false to avoid messages
  disp(sprintf(s,varargin{:})); %#ok<DSPS>
end;
