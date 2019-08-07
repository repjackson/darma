if Meteor.isClient
    Template.courses.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'course'
    Template.course.onCreated ->
        @autorun => Meteor.subscribe 'course', Router.current().params.course_code
        @autorun => Meteor.subscribe 'course_units', Router.current().params.course_code

    Template.courses.onRendered ->

    Template.courses.helpers
        courses: ->
            Docs.find {
                model:'course'
            }, sort:slug:1



    Template.course.helpers
        course: ->
            Docs.findOne
                model:'course'
                slug: Router.current().params.course_code

        units: ->
            Docs.find {
                model:'unit'
            }, sort: unit_number:1
                # course_slug:Router.current().params.course_code

    Template.courses.events
        'mouseenter .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').addClass('raised')
        'mouseleave .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').removeClass('raised')


    Template.course.events
        'keyup .unit_number': (e,t)->
            if e.which is 13
                unit_number = parseInt $('.unit_number').val().trim()
                course_number = parseInt $('.course_number').val()
                course_label = $('.course_label').val().trim()
                course = Docs.findOne model:'course'
                Docs.insert
                    model:'unit'
                    unit_number:unit_number
                    course_number:course_number
                    course_number:course_number
                    course_code:course_label

        'keyup .course_search': (e,t)->
            username_query = $('.username_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                if username_query.length > 1
                    # audio = new Audio('wargames.wav');
                    # audio.play();
                    Session.set 'username_query',username_query




if Meteor.isServer
    Meteor.publish 'course', (course_code)->
        Docs.find
            model:'course'
            slug:course_code


    Meteor.publish 'course_units', (course_code)->
        Docs.find
            model:'unit'
            course_code:course_code
