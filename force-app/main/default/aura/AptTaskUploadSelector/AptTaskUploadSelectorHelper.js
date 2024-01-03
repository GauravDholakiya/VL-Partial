({

     showSpinner: function(cmp) {
        // make Spinner attribute true for display loading spinner
        //cmp.set("v.spinner", true);
        var numOfRuns = cmp.get('v.numOfRuns');
        //console.log(numOfRuns);
        numOfRuns = numOfRuns + 1;
        //console.log('showSpinner2');
        //console.log(numOfRuns);
        cmp.set('v.numOfRuns', numOfRuns);
     },

        // this function automatic call by aura:doneWaiting event
     hideSpinner : function(cmp){
         var numOfRuns = cmp.get('v.numOfRuns');
         //console.log('hideSpinner');
         //console.log(numOfRuns);
         if (numOfRuns > 0){
            numOfRuns = numOfRuns - 1;
            cmp.set('v.numOfRuns', numOfRuns);
         }
        // make Spinner attribute to false for hide loading spinner
        //cmp.set("v.spinner", false);
     },

	initAPTTasks : function(component, event, helper) {
		//console.log('.......initAPTTasks');
		this.showSpinner(component);
        var tempOption = component.get('v.tempOptionValue');
        var action = component.get('c.fetchAPTaskTempates');
        var contractId = component.get('v.contractId');
        action.setParams({ templateType :tempOption, conId: contractId });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {                
                var custs = [];
                var conts = response.getReturnValue();
                for(var key in conts){
                    var opts = []; 
                    //console.log(conts[key]);
                	for (var val in conts[key]) {
                      // opts.push({label: conts[key][val], value: conts[key][val]});
                        opts.push(conts[key][val]);
                    }
                    //console.log('>>>>>opts: ');
                	//console.log(opts);
					custs.push({value:opts, key:key});                  
                }
                //console.log('>>>>>cuts: ');
                //console.log(custs);
                
                //console.log('>>>>>cuts1: ');
                //console.log(component.get("v.options"));
                component.set("v.apTaskList", custs);
                this.hideSpinner(component);
            } 
        });
        $A.enqueueAction(action);
            
            
	},

	closeModal: function(component, clear) {
        // Set isModalOpen attribute to false
        if (clear){
            this.clearSelectedTasks(component);
        }
        component.set("v.isUploadTasksModalOpen", false);
    },

    clearSelectedTasks: function(component){
        component.set("v.selectedTasks", []);
    },

    sendEvent: function(cmp, event){
        //console.log('sendEvent');
        var aptUploadTasksEvent = $A.get("e.c:AptUploadTasksEvt");
        var selectedTasks = cmp.get('v.selectedTasks');
        aptUploadTasksEvent.setParams({ "selectedTasks" : selectedTasks });
        aptUploadTasksEvent.fire();
    },
})