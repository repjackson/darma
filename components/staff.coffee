if Meteor.isClient
    Template.staff.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000



    Template.shift_change_requests.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift_change_request'


    Template.staff.onCreated ->
        # @autorun => Meteor.subscribe 'health_club_members', Session.get('username_query')
        # @autorun => Meteor.subscribe 'users'
        @autorun => Meteor.subscribe 'sessions'
        @autorun => Meteor.subscribe 'shift_walks'


    Template.staff.helpers
        checkedin_members: ->
            Docs.find
                model:'healthclub_session'
                active:true
        sessions: ->
            Docs.find
                model:'healthclub_session'
                active:true
                # model:$in:['healthclub_checkin','garden_key_checkout','unit_key_checkout']
        shift_walks: ->
            Docs.find
                model:'shift_walk'
                _author_id: Meteor.userId()

    Template.staff.events
        'click .log_staff_walked': ->
            if confirm 'Log hourly walk?'
                Docs.insert
                    model: 'shift_walk'
        'click .remove_walk': ->
            if confirm 'Remove walk log? Cannont be undone'
                Docs.remove @_id



    Template.hc_session.onCreated ->
        @autorun => Meteor.subscribe 'user_by_username', @data.resident_username
        @autorun => Meteor.subscribe 'session_guests', @data
    Template.hc_session.helpers
        icon_class: ->
            switch @session_type
                when 'healthclub_checkin' then 'treadmill'
                when 'garden_key_checkout' then 'basketball'
                when 'unit_key_checkout' then 'key'

        session_resident: ->
            Meteor.users.findOne
                username:@resident_username

        checkin_guest_docs: () ->
            Docs.find
                _id:$in:@guest_ids

    Template.hc_session.events
        'click .sign_out': (e,t)->
            # resident = Meteor.users.findOne
            #     username:@resident_username
            #
            # console.log @
            # if confirm "Check Out #{@first_name} #{@last_name}?"
            $(e.currentTarget).closest('.card').transition('fade up',500)
            Meteor.setTimeout =>
                Docs.update @_id,
                    $set: active: false
            , 500

        'click .garden_key_checkout': (e,t)->
            # healthclub_session_document = Docs.findOne
            #     model:'healthclub_session'
            Docs.update @_id,
                $set:
                    garden_key:true
                    submitted:true


        'click .check_in_garden_key': (e,t)->
            # healthclub_session_document = Docs.findOne
            #     model:'healthclub_session'
            Docs.update @_id,
                $set:
                    active:false
                    garden_key_checkin_timestamp: Date.now()
            $('body').toast({
                title: "Garden Key checked in."
                # message: 'See desk staff for key.'
                class : 'blue'
                position:'top right'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })






    Template.shift_change_requests.helpers
        requests: ->
            Docs.find {model:'shift_change_request'},
                sort: date: -1
    Template.shift_change_requests.events
        'click .add_shift_change_request': (e,t)->
            Docs.insert
                model:'shift_change_request'
    Template.request_row.events
        'click .declare_unavailable': (e,t)->
            Docs.update @_id,
                $addToSet:unavailable:Meteor.user().username
        'click .take_shift': (e,t)->
            Docs.update @_id,
                $set:assigned_staff:Meteor.user().username

    Template.task_widget.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'task'
    Template.task_widget.helpers
        tasks: ->
            Docs.find {model:'task'},
                sort: date: -1



    Template.unit_key_widget.onCreated ->
    Template.unit_key_widget.events
        'click .lookup_key': (e,t)->
            building_number = parseInt t.$('.building_number').val()
            unit_number = parseInt t.$('.unit_number').val()
            Meteor.call 'lookup_key',building_number, unit_number, (err,res)->
                alert "key tag number", res.tag_number

    Template.unit_key_widget.helpers
        tasks: ->
            Docs.find {model:'task'},
                sort: date: -1
    Template.unit_key_checkout.events
        'click .unit_key_checkout': (e,t)->
            # $(e.currentTarget).closest('.segment').transition('fade left',100)
            # Meteor.setTimeout =>
            $('body').toast({
                title: "Unit Key Checked Out #{@first_name} #{@last_name}"
                # message: 'See desk staff for key.'
                class : 'blue'
                position:'top right'
                # className:
                #     toast: 'ui massive message'
                displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
            # , 100
            Meteor.users.update @_id,
                $set:healthclub_checkedin:true
            Docs.insert
                model:'log_event'
                log_type:'unit_key_checkout'
                active:true
                object_id:@_id
                body: "#{@first_name} #{@last_name} checked out the unit key"



    Template.shift_checklist.onCreated ->
        @autorun => Meteor.subscribe 'todays_checklist'
        @autorun => Meteor.subscribe 'model_docs', 'shift_checklist'
        @autorun -> Meteor.subscribe 'model_fields', 'shift_checklist'

    Template.shift_checklist.events
        'click .create_checklist': ->
            Docs.insert
                model:'shift_checklist'

        'click .complete': ->
            console.log @
            console.log Template.parentData()
            todays_checklist =
                Docs.findOne
                    model:'shift_checklist'
            Docs.update todays_checklist._id,
                $set:
                    "#{@key}":true
                    "#{@key}_timestamp":Date.now()

        'click .incomplete': ->
            console.log @
            console.log Template.parentData()
            todays_checklist =
                Docs.findOne
                    model:'shift_checklist'
            Docs.update todays_checklist._id,
                $unset:
                    "#{@key}":1
                    "#{@key}_timestamp":1


    Template.shift_checklist.helpers
        todays_checklist: ->
            Docs.findOne
                model:'shift_checklist'

        completed_time: ->
            todays_checklist =
                Docs.findOne
                    model:'shift_checklist'
            todays_checklist["#{@key}_timestamp"]


        completed: ->
            checklist = Docs.findOne
                model:'shift_checklist'
            # console.log @
            checklist["#{@key}"]

        # checklist_items: ->
        #     Docs.find
        #         model:'shift_checklist'


        checklist_items: ->
            shift_checklist = Docs.findOne
                model:'shift_checklist'
            Docs.find
                model:'field'




if Meteor.isServer
    Meteor.methods
        lookup_key: (building_number, unit_number)->
            found_key = Docs.findOne
                model:'key'
                building_number:building_number
                unit_number:unit_number

    Meteor.publish 'sessions', ->
        Docs.find
            model:'healthclub_session'
            # model:$in:['healthclub_checkin','garden_key_checkout','unit_key_checkout']
            active:true


    Meteor.publish 'shift_walks', ()->
        # this_moment = moment(Date.now())
        # console.log this_moment.subtract(20, 'hours')
        hours = 1000*60*60*20
        now = Date.now()
        start_window = now-hours
        console.log start_window
        Docs.find
            model:'shift_walk'
            _author_id:Meteor.userId()
            _timestamp:$gt:start_window

    Meteor.publish 'session_guests', (session_data)->
        if session_data
            Docs.find
                _id:$in:session_data.guest_ids


    Meteor.publish 'todays_checklist', ->
        this_moment = moment(Date.now())
        # console.log this_moment.subtract(20, 'hours')
        hours = 1000*60*60*24
        now = Date.now()
        start_window = now-hours
        # console.log start_window
        Docs.find
            model:'shift_checklist'
            _author_id:Meteor.userId()
            _timestamp:$gt:start_window
