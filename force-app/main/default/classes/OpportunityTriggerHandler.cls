public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private List<Opportunity> newOpp;
    private List<Opportunity> oldOpp;
    private Map<Id, Opportunity> newOppMap;
    private Map<Id, Opportunity> oldOppMap;

    public OpportunityTriggerHandler() {
        this.oldOpp = (List<Opportunity>) Trigger.old;
        this.newOpp = (List<Opportunity>) Trigger.new;
        this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    //public override void beforeInsert() {}

    //public override void afterInsert() {}
}