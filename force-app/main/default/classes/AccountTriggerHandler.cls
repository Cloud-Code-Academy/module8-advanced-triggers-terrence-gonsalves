public with sharing class AccountTriggerHandler extends TriggerHandler {
    private List<Account> newAcct;
    private List<Account> oldAcct;
    private Map<Id, Account> newAcctMap;
    private Map<Id, Account> oldAcctMap;

    AccountHelper accHelper = new AccountHelper();

    public AccountTriggerHandler() {
        this.oldAcct = (List<Account>) Trigger.old;
        this.newAcct = (List<Account>) Trigger.new;
        this.newAcctMap = (Map<Id, Account>) Trigger.newMap;
        this.oldAcctMap = (Map<Id, Account>) Trigger.oldMap;
    }

    public override void beforeInsert() {

        /*
        * Account Trigger
        * When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
        * Trigger should only fire on insert.
        */ 
        accHelper.setTypeProspect(newAcct);

        /*
        * Account Trigger
        * When an account is inserted copy the shipping address to the billing address.
        * Trigger should only fire on insert.
        */
        accHelper.addressCopy(newAcct); 

        /*
        * Account Trigger
        * When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax is not empty.
        * Trigger should only fire on insert.
        */
        accHelper.setRating(newAcct);
    }

    public override void afterInsert() {

        /*
        * Account Trigger
        * When an account is inserted create a contact related to the account with the following default values:
        * LastName = 'DefaultContact'
        * Email = 'default@email.com'
        * Trigger should only fire on insert.
        */     
         accHelper.defaultContact(newAcct);
    }
}