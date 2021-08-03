/**
 * @description JS helper for mkFileListWithIcons
 * @author      Scott Taylor, Traction on Demand
 * @date        2020-10-23
 */
let helper = {
    /**
     * @description Format the incoming file data for display
     * @author      Scott Taylor, Traction on Demand
     * @date        2020-10-23
     *
     * @param incomingFileData  List of file data to format
     *
     * @return      Formatted file list
     */
    formatFileDataForMarkup: (incomingFileData) => {
        let _fileList = [];
        if (!incomingFileData) {
            return _fileList;
        }

        incomingFileData.forEach((documentLink) => {
            let lineToPush = {
                contentDocumentId : documentLink.contentDocumentId,
                title : documentLink.title
            };

            let fileExtension = documentLink.fileType.toLowerCase();

            switch (fileExtension) {
                case "jpg":
                case "jpeg":
                case "png":
                case "gif":
                    lineToPush.imageFile = true;
                    lineToPush.imageUrl = documentLink.imageUrl;
                    break;
                default:
                // do nothing
            }

            _fileList.push(lineToPush);
        });

        return _fileList;
    }
};

export { helper };