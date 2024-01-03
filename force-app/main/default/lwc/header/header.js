import { LightningElement } from 'lwc';
import LOGO from '@salesforce/resourceUrl/Logo';
import noHeader from '@salesforce/resourceUrl/noHeader';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class header extends LightningElement {
    logourl = LOGO;

    //hides the default header
    connectedCallback() {
        loadStyle(this, noHeader)
    }
}