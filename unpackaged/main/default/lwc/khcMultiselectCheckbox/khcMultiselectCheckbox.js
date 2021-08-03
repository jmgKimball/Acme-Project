import { LightningElement, api } from 'lwc';

export default class KhcMultiselectCheckbox extends LightningElement {
    @api showPill;
    @api label;
    @api options;
    @api placeholder;
    @api selectedOptions = [];

    @api dropdownPosition;

    selOptions = [];
    selectedOption = '';
    showOptions = false;

    connectedCallback(){
        if( this.selectedOptions ){
            this.selOptions = [ ...this.selectedOptions ];
        }
    }

    renderedCallback(){
        let checkboxOptions = this.template.querySelectorAll('.option-checkbox');
        if( checkboxOptions ){
            checkboxOptions.forEach( inputComp => {
                if( this.selOptions.length > 0 &&
                    this.selOptions.indexOf( inputComp.dataset.value ) >= 0 ){
                    inputComp.checked = true;
                }
            });
        }
        //mark filter as active 
        if( this.showPill ){
            let pill = this.template.querySelector('.khc-slds-pill');
            if( this.selOptions.length > 0 ){
                pill.classList.add('slds-pill-active');
            }else{ 
                pill.classList.remove('slds-pill-active');
            }
        }
    }

    @api closeDropdown () {
        this.showOptions = false;
    }

    handleSelectOption(event){
        this.showOptions = !this.showOptions;

        const openEvt = new CustomEvent( "dropdown", { detail: this.showOptions } );
        this.dispatchEvent( openEvt );
    }

    handleOptionSelection( evt ){
        if( evt.detail.checked ){
            this.selOptions.push( evt.target.dataset.value );
        }else{
            this.removeSelectedOption( evt.target.dataset.value );
        }

        let selectedOption = '';
        this.selOptions.forEach( topic => {
            selectedOption += topic + ';';
        });
        this.selectedOption = selectedOption;
        //Send values to parent
        let eventValue = {};
        eventValue.selectedOptions = this.selOptions;
        eventValue.selectedOptionsStr = this.selectedOption;
        const changeEvt = new CustomEvent( "change", { detail: eventValue} );
        this.dispatchEvent( changeEvt );
    }

    removeSelectedOption( itemName ) {
        let selectedOptions = this.selOptions;
        selectedOptions.forEach(function(item, idx){
            if ( itemName == item ) {
                selectedOptions.splice( idx, 1 );
            }
        });
        this.selOptions = selectedOptions;
    }

    get sldsDropdownClasses () {
        let dropdownClasses = 'khc-multiselect-dropdown-wrapper slds-dropdown slds-dropdown_length-10 slds-dropdown_fluid slds-has-focus';
        if ( this.dropdownPosition == 'right' ) {
            dropdownClasses += ' slds-dropdown_right';
        } else if ( this.dropdownPosition == 'left' ) {
            dropdownClasses += ' slds-dropdown_left';
        }
        return dropdownClasses;
    }
}