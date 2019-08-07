if Meteor.isClient
    Template.manager.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift_walk'
        @autorun => Meteor.subscribe 'last_days_healthclub_sessions'


    Template.manager.helpers
        'shift_walks': ->
            Docs.find
                model:'shift_walk'

        'check_ins': ->
            Docs.find
                model:'healthclub_session'


if Meteor.isServer
    Meteor.publish 'last_days_healthclub_sessions', ->
        # this_moment = moment(Date.now())
        # console.log this_moment.subtract(20, 'hours')
        hours = 1000*60*60*24
        now = Date.now()
        start_window = now-hours
        console.log start_window
        Docs.find
            model:'healthclub_session'
            # _author_id:Meteor.userId()
            _timestamp:$gt:start_window
