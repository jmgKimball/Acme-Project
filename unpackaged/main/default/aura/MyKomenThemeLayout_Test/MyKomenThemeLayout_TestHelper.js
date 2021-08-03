/**
 * Created by mlandels on 2021-05-11.
 */

({
    getCurrentUrlPath : function () {
        let currentPath = window.location.pathname;
        if ( currentPath && currentPath != '/s/' ) {
            return currentPath.replace('/', '%2F');;
        }
    }
});