({
    doInit : function (component) {
         console.log('ID: ' +component.get("v.contractId"));
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's Unique Name.
        var inputVariables = [
      		{
                name : 'ContractId',
                type : 'String',
                value : component.get("v.contractId")
      		}
      
    ]; 
        flow.startFlow("Task_Manager", inputVariables);
    },
})