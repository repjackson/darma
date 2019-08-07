if Meteor.isClient
    Template.view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params._id
        @autorun -> Meteor.subscribe 'schema', Router.current().params._id
