class @ContentView extends Backbone.View
    initialize: (@url) ->
        @el = $('#content')
        @delegateEvents()
        @el.scroll =>
            @setZoomToScroll()
        @length = 600 # STUB

        @audio = document.createElement('audio');
        src = document.createElement('source')
        src.setAttribute('src', @url)
        @audio.appendChild(src)
        @audio.addEventListener 'load', =>
            @length = @audio.duration
        @audio.load()

        @cues = []

    events:
        'click #zoomin': 'zoomIn'
        'click #zoomout': 'zoomOut'

    zoomIn: (ev) ->
        ev.preventDefault()
        console.log "zoomIn"
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart + (zoomSpan * 0.1), @zoomEnd - (zoomSpan * 0.1)

    zoomOut: (ev) ->
        ev.preventDefault()
        console.log "zoomOut"
        zoomSpan = @zoomEnd - @zoomStart
        @zoomTo @zoomStart - (zoomSpan * 0.1), @zoomEnd + (zoomSpan * 0.1)

    getFullWidth: ->
        winWidth = @el.innerWidth()
        zoomSpan = @zoomEnd - @zoomStart
        Math.ceil(winWidth * @length / zoomSpan)

    zoomTo: (@zoomStart, @zoomEnd) ->
        console.log "zoomTo #{@zoomStart} #{@zoomEnd}"
        # Normalize first
        if isNaN(@zoomStart)
            @zoomStart = 0
        if isNaN(@zoomEnd)
            @zoomEnd = @length
        if @zoomStart < 0
            @zoomEnd -= @zoomStart
            @zoomStart = 0
        if @zoomEnd > @length
            @zoomStart -= @zoomEnd - @length
            @zoomEnd = @length
        if @zoomStart < 0
            @zoomStart = 0
        @emitZoomUpdate()
        console.log "zoomTo' #{@zoomStart} #{@zoomEnd}"

        fullWidth = @getFullWidth()
        #@el.css('width', "#{fullWidth}px")
        $('#dummy').css('left', "#{fullWidth - 4}px")
        @el.scrollLeft Math.floor(@zoomStart * fullWidth / @length)

        # Move cues around:
        for cue in @cues
            x = fullWidth * cue.start / @length
            cue.css('left', "#{x}px")

        @realign()

    setZoomToScroll: ->
        winWidth = @el.innerWidth()
        left = @el.scrollLeft()
        right = left + winWidth
        @zoomStart = left * @length / winWidth
        @zoomEnd = right * @length / winWidth
        console.log "setZoomToScroll l=#{left} r=#{right} ww=#{winWidth} zs=#{@zoomStart} ze=#{@zoomEnd}"
        @emitZoomUpdate()

        @realign()

    realign: ->
        console.log "realign #{@zoomStart}..#{@zoomEnd}"
        # Fixed stuff:
        left = @el.scrollLeft()
        @$('#buttons').css('left', "#{left}px")
        @$('#waveform').css('left', "#{left}px")
        @$('h3').each (i) ->
            console.log "i=#{i}"
            $(@).css('left', "#{left + 4}px")
            $(@).css('top', "#{12 + 4 * i}em")

    emitZoomUpdate: ->
        if @onZoomUpdate
            @onZoomUpdate @zoomStart, @zoomEnd