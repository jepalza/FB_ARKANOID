 
' Prototypes.
Declare Sub AnmInitEngine() 
Declare Function AnmSet( pAnm As u32 Ptr , nSlotNo As s32) As s32 
Declare Function AnmSetIfNew( pAnm As u32 Ptr , nSlotNo As s32) As s32 
Declare Sub AnmReleaseSlot(nSlotNo As s32) 
Declare Function AnmGetImage(nSlotNo As s32) As s32 
Declare Function AnmGetLastImage(nSlotNo As s32) As s32 
Declare Function AnmGetKey(nSlotNo As s32) As u32 
Declare Function AnmCheckEnd(nSlotNo As s32) As u32 


