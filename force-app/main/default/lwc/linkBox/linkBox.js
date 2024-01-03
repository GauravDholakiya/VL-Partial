// Created June 2020 - Mia Genovese, Fluido
// Used for the View Academy App
/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getFilteredLinks from '@salesforce/apex/LinkController.getFilteredLinks';
import getUserPermissions from '@salesforce/apex/LinkController.getUserPermissions';
import getCountryPicklistValues from '@salesforce/apex/LinkController.getCountryPicklistValues';
import getTypePicklistValues from '@salesforce/apex/LinkController.getTypePicklistValues';
import Id from '@salesforce/user/Id'

export default class LinkBox extends LightningElement {
    @track data = true;
    @track links;
    @track error;
    @track openmodel = false;
    @track openRecordEditForm = false;
    @track linkId;
    @track targetRecordId;
    wiredlinksResult;

    //for sorting the Type and Country columns
    @track error;
    sortedDirection = "asc";
    sortedColumn;
    @track arrow;
    @track iconCountry = false;
    @track iconType = false;
    @track iconDate = false;
    @track iconDescription = false;
    @track iconLink = false;
    @track iconName = false;

    //for the options in the Type and Country
    @track privateMenuItemsType = [];
    @track privateMenuItemsCountry = [];    
    @track checked = false;
    @track disabled = false;
    selectedTypes = [];
    selectedCountries = [];
    firstWireCountry = true;
    firstWireType = true;
    searchTerm = '';
    @track loading = false;

    firstrunCountry = true;
    clearCountry = false;
    firstrunType = true;
    clearType = false;

    //for the Care permission set and System Admins
    @track hasPermissions = false;
    userId = Id;
    wiredPermissions = false;
    
    @wire(getFilteredLinks,{ types: '$selectedTypes', countries: '$selectedCountries', searchTerm: '$searchTerm'})
    wiredLinks(result) {
        this.loading = true;
        this.wiredLinksResult = result;
        if(result.data) {
            this.links = result.data;
            this.error = undefined;
            this.loading = false;
            this.data = this.hasData(result.data);
        } else{
            this.data = false;
            this.links = undefined;
        }
    }

    @wire(getUserPermissions, {userId: '$userId'})
    wiredUser(result) {
        if(result.data) {
            this.hasPermissions = result.data;
        } else if (result.error) {
            this.error = error;
        }
    }
    
    @wire(getCountryPicklistValues) 
    countries({ error, data}) {
        if(data) {
            var array = JSON.stringify(data).split(',');
            for(var i = 0; i <array.length; i++){
                array[i] = array[i].replace(/\"/g, "").replace(/\[/g, "").replace(/\]/g, "");
                var newItem = {
                    id: 'menu-item-' + i.toString(),
                    label: array[i],
                    value: array[i],
                    checked: false,
                    disabled: false,
                }
                this.privateMenuItemsCountry.push(newItem);
            }
            this.disableOptionsCountry();
            this.handleSelectAllCountry();
            this.firstrunCountry = true;
            this.error = undefined; 
        } else if (error) {
            this.error = error;
            this.privateMenuItemsCountry = undefined;
        }
    }

    @wire(getTypePicklistValues) 
    type({ error, data}) {
        if(data) {
            var array = JSON.stringify(data).split(',');
            for(var i = 0; i <array.length; i++){
                array[i] = array[i].replace(/\"/g, "").replace(/\[/g, "").replace(/\]/g, "");
                var newItem = {
                    id: 'menu-item-' + i.toString(),
                    label: array[i],
                    value: array[i],
                    checked: false,
                    disabled: false,
                }
                this.privateMenuItemsType.push(newItem);
            }
            this.disableOptionsType();
            this.handleSelectAllType();
            this.firstrunType = true;
            this.error = undefined; 
        } else if (error) {
            this.error = error;
            this.privateMenuItemsType = undefined;
        }
    }

    hasData(obj){
        for(var key in obj) {
            if(obj.hasOwnProperty(key))
            return true;
        }
        return false;
    }

    openModal() {
        this.openmodel = true;
    }
    closeModal() {
        this.openmodel = false;
    }

    handleEditLink(event){
        this.openRecordEditForm = true;
        const selectedRecord = event.currentTarget.dataset.key;
        this.targetRecordId = selectedRecord;
    }

    handleDeleteLink(event){
        deleteRecord(event.currentTarget.dataset.key)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Link Deleted',
                    variant: 'success',
                }),
            );
            this.firstWireType = true;
            this.firstWireCountry = true;
            refreshApex(this.wiredLinksResult)
            .then(() => {
                this.disableOptions();
            });
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting link',
                    message: error.message.body,
                    variant: 'error',
                }),
            );
        });   
      }

    disableOptions(){
        this.firstWireType = true;
        this.firstWireCountry = true;
        this.disableOptionsCountry();
        this.disableOptionsType();
    }

    closeEditModal(){
        this.openRecordEditForm = false;
    }

    handleSuccess() {
        const evt = new ShowToastEvent({
            title: "Success!",
            message: "The link has been successfully saved.",
            variant: "success",
        });
        this.dispatchEvent(evt);
        this.closeEditModal();
        this.closeModal();
        this.firstWireType = true;
        this.firstWireCountry = true;
        refreshApex(this.wiredLinksResult)
        .then(() => {
            this.disableOptions();
        });
    }

    handleError() {
        const evt = new ShowToastEvent({
            title: "Error!",
            message: "An error occurred while attempting to save the record.",
            variant: "error",
        });
        this.dispatchEvent(evt);
    }

    sort(event){ //sorting functions
        if(this.sortedColumn === event.currentTarget.dataset.id){
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        }else{
            this.sortedDirection = 'asc';
        }
        this.sortedColumn = event.currentTarget.dataset.id; 
        
        if(this.sortedColumn === "Type__c"){
            this.iconType = true;
            this.iconCountry = false;
            this.iconDate = false;
            this.iconDescription = false;
            this.iconLink = false;
            this.iconName = false;
            this.arrow = this.sortedDirection === 'asc' ? "utility:arrowup" : "utility:arrowdown"
        }
        if(this.sortedColumn === "Country__c"){
            this.iconCountry = true;
            this.iconType = false;
            this.iconDate = false;
            this.iconDescription = false;
            this.iconLink = false;
            this.iconName = false;
            this.arrow = this.sortedDirection === 'asc' ? "utility:arrowup" : "utility:arrowdown"
        }
        if(this.sortedColumn === "LastModifiedDate"){
            this.iconDate = true;
            this.iconType = false;
            this.iconCountry = false;
            this.iconDescription = false;
            this.iconLink = false;
            this.iconName = false;
            this.arrow = this.sortedDirection === 'asc' ? "utility:arrowup" : "utility:arrowdown"
        }
        if(this.sortedColumn === "Description__c"){
            this.iconDescription = true;
            this.iconDate = false;
            this.iconType = false;
            this.iconCountry = false;
            this.iconLink = false;
            this.iconName = false;
            this.arrow = this.sortedDirection === 'asc' ? "utility:arrowup" : "utility:arrowdown"
        }
        if(this.sortedColumn === "Link_url__c"){
            this.iconDescription = false;
            this.iconDate = false;
            this.iconType = false;
            this.iconCountry = false;
            this.iconLink = true;
            this.iconName = false;
            this.arrow = this.sortedDirection === 'asc' ? "utility:arrowup" : "utility:arrowdown"
        }
        if(this.sortedColumn === "Name"){
            this.iconDescription = false;
            this.iconDate = false;
            this.iconType = false;
            this.iconCountry = false;
            this.iconLink = false;
            this.iconName = true;
            this.arrow = this.sortedDirection === 'asc' ? "utility:arrowup" : "utility:arrowdown"
        }
        var reverse = this.sortedDirection === 'asc' ? 1 : -1;
        const table = [...this.links];

        table.sort((a,b) => {return a[event.currentTarget.dataset.id].toLowerCase() > b[event.currentTarget.dataset.id].toLowerCase() ? 1 * reverse : -1 * reverse});       
        this.links = table;  
    }

    handleTypeFilter(event) { //filter function for Type column
        const selectedItemValue = event.detail.value;
        this.firstrunType = true;
        if(selectedItemValue === "Select all" ){
            this.handleSelectAllType();
        }
        else{
            this.handleprivateMenuItemsType(event);
        }     
    }

    handleCountryFilter(event) { //filter function for Country column
        const selectedItemValue = event.detail.value;
        this.firstrunCountry = true;
        if(selectedItemValue === "Select all" ){
            this.handleSelectAllCountry();
        }
        else{
            this.handleprivateMenuItemsCountry(event);
        }  
    }

    handleSelectAllType(){
        if(this.clearType == true){
            this.handleClearType();
            return;
        }
        if(this.firstrunType == false){
            return;
        }
        this.selectedTypes = [];
        console.log('in handleSelectAllTypes');
        for(var i = 0; i < this.privateMenuItemsType.length; i++){
            this.selectedTypes.push(this.privateMenuItemsType[i].value);
            this.privateMenuItemsType[i].checked = true;
        }
        this.data = true;
        this.firstrunType = false;
        this.clearType = true;
        this.selectedTypes = JSON.stringify(this.selectedTypes);
    }

    handleClearType(){
        console.log('in handleClear');
        for(var i = 0; i < this.privateMenuItemsType.length; i++){
            this.privateMenuItemsType[i].checked = false;
        }
        this.data = false;
        this.firstrunType = true;
        this.clearType = false;
        // array = [];
        // this.links = array;
        //this.selectedCountries = JSON.stringify(array);
    }

    handleClearCountry(){
        console.log('in handleClear');
        for(var i = 0; i < this.privateMenuItemsCountry.length; i++){
            this.privateMenuItemsCountry[i].checked = false;
        }
        this.data = false;
        this.firstrunCountry = true;
        this.clearCountry = false;
        // array = [];
        // this.links = array;
        //this.selectedCountries = JSON.stringify(array);
    }

    handleSelectAllCountry(){
        if(this.clearCountry == true){
            this.handleClearCountry();
            return;
        }
        if(this.firstrunCountry == false){
            return;
        }
        this.selectedCountries = [];
        console.log('in handleSelectAllCountry');
        for(var i = 0; i < this.privateMenuItemsCountry.length; i++){
            this.selectedCountries.push(this.privateMenuItemsCountry[i].value);
            this.privateMenuItemsCountry[i].checked = true;
        }
        this.data = true;
        this.firstrunCountry = false;
        this.clearCountry = true;
        this.selectedCountries = JSON.stringify(this.selectedCountries);
    }

    handleprivateMenuItemsCountry(event){ //handles individual selection of Country filter
        console.log('in handleprivatemenuItemsCountry');
        this.firstWireCountry = false;
        this.selectedCountries = [];
        const selectedItemValue = event.detail.value;
        const menuItem = this.privateMenuItemsCountry.find(function(item) {
            return item.value === selectedItemValue;
        });

        this.checked = !menuItem.checked;
        this.selectAllCheckedCountry = false;
        this.clearCheckedCountry = false;

        menuItem.checked = this.checked;
        for(var i = 0; i < this.privateMenuItemsCountry.length; i++){
            if(this.privateMenuItemsCountry[i].checked == true){
                this.selectedCountries.push(this.privateMenuItemsCountry[i].value);
            }
        }
        this.firstrunCountry = true;
        this.selectedCountries = JSON.stringify(this.selectedCountries);
    }

    handleprivateMenuItemsType(event){
        this.firstWireType = false;
        this.selectedTypes = [];
        const selectedItemValue = event.detail.value;
        const menuItem = this.privateMenuItemsType.find(function(item) {
            return item.value === selectedItemValue;
        });

        this.checked = !menuItem.checked;

        menuItem.checked = this.checked;
        for(var i = 0; i < this.privateMenuItemsType.length; i++){
            if(this.privateMenuItemsType[i].checked == true){
                this.selectedTypes.push(this.privateMenuItemsType[i].value);
            }
        }
        this.firstrunType = true;
        this.selectedTypes = JSON.stringify(this.selectedTypes);
    }

    //disables options for filter if not in database
    disableOptionsCountry(){
        if(this.firstWireCountry == false || this.links == undefined){
            return;
        }
        console.log('in disabled optionsCountry');
        const countrySet = [];
        for(var x = 0; x < this.links.length; x++){
            var country = JSON.stringify(this.links[x].Country__c);
            countrySet.push(country);
        }
        console.log('countrySet' + countrySet);

        for(var i = 0; i < this.privateMenuItemsCountry.length; i++){
            var option = JSON.stringify(this.privateMenuItemsCountry[i].value);
            if(countrySet.includes(option)){
                this.privateMenuItemsCountry[i].disabled = false;
            } else {
                this.privateMenuItemsCountry[i].disabled = true;
            }
        }
        this.firstWireCountry = false;
    }
    //disables options for filter if not in database
    disableOptionsType(){
        if(this.firstWireType == false || this.links == undefined){
            return;
        }
        console.log('in disabled optionsType');
        const typeSet = [];
        for(var x = 0; x < this.links.length; x++){
            var type = JSON.stringify(this.links[x].Type__c);
            typeSet.push(type);
        }
        console.log('typeSet' + typeSet);
        for(var i = 0; i < this.privateMenuItemsType.length; i++){
            var option = JSON.stringify(this.privateMenuItemsType[i].value);
            if(typeSet.includes(option)){
                this.privateMenuItemsType[i].disabled = false;
            } else {
                this.privateMenuItemsType[i].disabled = true;
            }
            
        }

        this.firstWireType = false;
    }
    //search bar functionality
    handleKeyUp(event){
        const isEnterKey = event.keyCode === 13;
        if(isEnterKey) {
            this.searchTerm = event.target.value
        }
        console.log('queryTerm' + this.searchTerm);
    }
}