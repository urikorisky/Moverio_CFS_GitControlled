classdef (ConstructOnLoad) FileSelectEventData < event.EventData
   properties
      filePath
   end
   
   methods
      function data = FileSelectEventData(filePath)
         data.filePath = filePath;
      end
   end
end