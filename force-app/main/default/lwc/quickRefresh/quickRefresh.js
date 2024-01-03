import { LightningElement } from 'lwc';

export default class QuickRefresh extends LightningElement {
    connectedCallback(){
        setTimeout(() => {

            eval("$A.get('e.force:refreshView').fire();");

        });
    }
}