global class ScheduleMassDeleteDocument implements Schedulable{
    global void execute(SchedulableContext ctx) {
        String jobID = Database.executeBatch(new MassDeleteDocuments());
    }
}