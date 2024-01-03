/**
 * @author Jozef 
 * @date 24.1.2019.
 * @description //TODO
 */
({

    doInit : function(cmp, event, helper) {

    },

     handleSelectedRowsEvent : function(cmp, event, helper) {
           console.log('EVENT OK');
           var headerId = event.getParam("headerId");
           var aptIndex = event.getParam("index");

           console.log("-----------------");
           console.log(aptIndex);
           //console.log(comments);
           console.log("-----------------");

           cmp.set("v.headerId", headerId);



           var apTasks = cmp.get('v.apTasks');
           cmp.set('v.apTask', apTasks[aptIndex]);

           helper.readAttachments(cmp, headerId);
     }
})