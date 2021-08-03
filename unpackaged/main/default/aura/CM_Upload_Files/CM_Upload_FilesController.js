({
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "File "+fileName+" Uploaded successfully."
        });
        toastEvent.fire();
        $A.get('e.lightning:openFiles').fire({
            recordIds: [documentId]
        
        });
       
    }
})

/*$A.enqueueAction(action); */
/*({
import { LightningElement, api } from 'lwc';
export default class MyComponentName extends LightningElement {
    @api
    RecordId;

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }
    
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "File "+fileName+" Uploaded successfully."
        });
        toastEvent.fire();
        
        $A.get('e.lightning:openFiles').fire({
            recordIds: [documentId]
        });
        
    }

    /*handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert("No. of files uploaded : " + uploadedFiles.length);
    }
}
})*/