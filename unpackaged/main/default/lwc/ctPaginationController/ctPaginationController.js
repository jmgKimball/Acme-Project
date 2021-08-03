/**
 * Simple client-side paginator used by clinical trials list component
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2020-05-26
 */
class CtPaginationController {
    _recordCount = 0;
    _pageSize = 1;
    _currentPage = 1;
    _pages = [];

    constructor(pageSize) {
        this._pageSize = pageSize;
    }

    setRecords(records) {
        this._recordCount = records.length;
        const recordCopy = [...records]; // clone the array since we will alter it during pagination
        while(recordCopy.length) {
            this._pages.push(recordCopy.splice(0, this._pageSize));
        }
    }

    get recordCount() {
        return this._recordCount;
    }

    get pageCount() {
        return this._pages.length;
    }

    get currentPage() {
        return this._currentPage;
    }

    getNext() {
        if(!this.isMax()) {
            this._currentPage++;
        }

        return this.getPage();
    }

    getPrev() {
        if(!this.isMin()) {
            this._currentPage--;
        }

        return this.getPage();
    }

    getPage(pageNumber) {
        const pageNum = this._isValidPage(pageNumber) ? pageNumber : this._currentPage;
        return this._pages[pageNum - 1];
    }

    _isValidPage(pageNumber) {
        return !!pageNumber && pageNumber > 0 && pageNumber <= this._pages.length;
    }

    isMin() {
        return this._currentPage === 1;
    }

    isMax() {
        return this._currentPage === this._pages.length;
    }
}

export {CtPaginationController}