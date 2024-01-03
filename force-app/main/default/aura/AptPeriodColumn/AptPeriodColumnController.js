/**
 * Created by jozef on 29. 3. 2023.
 */

({
    doInit: function(cmp, event, helper) {
        helper.setTaskDetails(cmp);

    },

    onRender: function(cmp, event, helper) {

    },

    handleSummaryClick: function(cmp, event, helper) {
       let periodLink = cmp.find("periodLink");
       let docElement;
       if (periodLink){
           docElement = periodLink.getElement();
           let bcr = docElement.getBoundingClientRect();
           cmp.set('v.periodLinkLeft', bcr.left);
           cmp.set('v.periodLinkTop', bcr.top);
       }
       cmp.set('v.toolTipDisplay', true);
    },

});