module Main exposing (App)

import Alert exposing (Alert, fire)
import Alert.Queue as Queue exposing (Queue)
import Browser exposing (Document, UrlRequest)
import Browser.Dom as Dom
import Browser.Events
import Browser.Navigation as Nav
import Cache exposing (Cache)
import Config.App as App
import Device
import Element exposing (..)
import Json.Encode exposing (Value)
import LoggedInUser exposing (LoggedInUser)
import Main.Flags as Flags
import Page
import Page.Editor
import Page.Feeds
import Page.Help
import Page.Home
import Page.Inbox
import Page.Login
import Page.NotFound
import Page.Post
import Page.PrivacyPolicy
import Page.Profile
import Page.Redirect
import Page.Register
import Page.Search
import Page.Settings
import Page.Starred
import Page.Tools
import Post exposing (Post, Preview)
import Process
import Route exposing (Href, Route)
import Session exposing (Session(..))
import Settings exposing (Settings)
import Task
import Url exposing (Url)
import User exposing (User)



-- Model


type App
    = RedirectState Global Href
    | NotFoundState Global ()
    | HomeState Global ()
    | FeedsState Global Page.Feeds.State
    | EditorState Global Page.Editor.State LoggedInUser
    | SearchState Global Page.Search.State
    | ToolsState Global Page.Tools.State
    | StarredState Global Page.Starred.State LoggedInUser
    | InboxState Global Page.Inbox.State LoggedInUser
    | SettingsState Global Page.Settings.State LoggedInUser
    | RegisterState Global Page.Register.State
      {- NOTE: There is no LogoutState because logging out can be handled by `transition` without
         the need for an actual interim state existing.
      -}
    | LoginState Global Page.Login.State
    | ProfileState Global Page.Profile.State
    | PostState Global Page.Post.State
    | HelpState Global ()
    | PrivacyPolicyState Global ()


type alias Global =
    { session : Session
    , devpro : Device.Profile
    , alerts : Queue
    , searchCache : Cache (Post Preview)
    , settings : Settings
    }



-- Messages


type Msg
    = Ignored
    | EffectDelayed Effect
    | LoadingTimedOut -- Display a loading spinner… (should be roughly 200-600ms)
    | LinkClicked UrlRequest
    | RouteChanged Route
    | ResizedDevice Device.Profile
    | AlertRequested (Alert.Id -> Alert)
    | AlertFired Alert
    | AlertExpired Alert
      -- Pages
    | EditorMessaged (Page.Editor.Msg Msg)
    | SearchMessaged (Page.Search.Msg Msg)
    | InboxMessaged (Page.Inbox.Msg Msg)
    | SettingsMessaged (Page.Settings.Msg Msg)
    | RegisterMessaged (Page.Register.Msg Msg)
    | LoginMessaged (Page.Login.Msg Msg)



-- Effects


type Effect
    = Effects (List Effect)
    | NoEffect -- No-op
    | DelayEffect Float Effect
    | DelayMsg Float Msg
    | PushRoute Route
    | ReplaceRoute Route
    | Redirect Href
    | FireAlert (Alert.Id -> Alert)
    | ExpireAlert Alert
      -- Pages
    | EditorEffect Page.Editor.Effect
    | SearchEffect Page.Search.Effect
    | ToolsEffect Page.Tools.Effect
    | StarredEffect Page.Starred.Effect
    | InboxEffect Page.Inbox.Effect
    | SettingsEffect Page.Settings.Effect
    | RegisterEffect Page.Register.Effect
    | LoginEffect Page.Login.Effect
    | PostEffect Page.Post.Effect
    | ProfileEffect Page.Profile.Effect



-- Main, Init & Subscriptions


main : Program Value App Msg
main =
    let
        performEffect ( app, effect ) =
            let
                global =
                    globalState app

                navKey =
                    Session.navKey global.session
            in
            ( app, perform navKey effect )
    in
    Browser.application
        { init = \json url key -> init json url key |> performEffect
        , subscriptions = subscriptions
        , update = \msg model -> update msg model |> performEffect
        , onUrlRequest = LinkClicked
        , onUrlChange = RouteChanged << Route.routeUrl
        , view = view
        }


init : Value -> Url -> Nav.Key -> ( App, Effect )
init json url navKey =
    let
        flags =
            Flags.decode json

        initRoute =
            Route.routeUrl url

        ( initAppState, initEffect ) =
            start initRoute <|
                { session = Session.new navKey App.startUser
                , devpro = Device.profile flags.size
                , alerts = Queue.empty
                , searchCache = Cache.empty
                , settings = Settings.default
                }
    in
    Effects [ initEffect, DelayMsg 350 LoadingTimedOut ]
        |> Tuple.pair initAppState


subscriptions : App -> Sub Msg
subscriptions app =
    let
        global =
            globalState app
    in
    Sub.batch
        [ Browser.Events.onResize <|
            Device.resizeHandler global.devpro
                { resized = ResizedDevice
                , noOp = Ignored
                }
        ]



-- Update


update : Msg -> App -> ( App, Effect )
update msg app =
    let
        global =
            globalState app

        ignore =
            ( app, NoEffect )

        navKey =
            Session.navKey global.session
    in
    case msg |> App.logMsg [ Ignored ] of
        Ignored ->
            ignore

        EffectDelayed effect ->
            ( app, effect )

        LoadingTimedOut ->
            -- TODO: Write loading spinner logic.
            ignore

        LinkClicked (Browser.Internal url) ->
            let
                nextRoute =
                    Route.routeUrl url
            in
            ( app, PushRoute nextRoute )

        LinkClicked (Browser.External href) ->
            Browser.External href
                |> App.logProblem "External link accidently embedded in the page (NOTE: Use the app's link redirection mechanism)" ignore

        RouteChanged newRoute ->
            app |> transition newRoute

        ResizedDevice devpro ->
            ( { global | devpro = devpro } |> updateApp app, NoEffect )

        AlertRequested alert ->
            ( app, FireAlert alert )

        AlertFired alert ->
            let
                allowed =
                    global.settings.alerts
                        || not (Alert.canSilence alert)

                nextQueue =
                    if allowed then
                        global.alerts |> Queue.push alert

                    else
                        global.alerts
            in
            ( { global | alerts = nextQueue } |> updateApp app, ExpireAlert alert )

        AlertExpired alert ->
            ( { global | alerts = global.alerts |> Queue.remove alert } |> updateApp app
            , NoEffect
            )

        -- Settings Page
        --
        SettingsMessaged (Page.Settings.ParentMsg myMsg) ->
            app |> update myMsg

        SettingsMessaged submsg ->
            case app of
                SettingsState _ local loggedInUser ->
                    let
                        ( nextLocal, effect ) =
                            Page.Settings.update submsg local
                    in
                    ( SettingsState global nextLocal loggedInUser
                    , SettingsEffect effect
                    )

                _ ->
                    ignore

        -- Editor Page
        --
        EditorMessaged (Page.Editor.ParentMsg myMsg) ->
            app |> update myMsg

        EditorMessaged submsg ->
            case app of
                EditorState _ local loggedInUser ->
                    let
                        ( nextLocal, effect ) =
                            Page.Editor.update submsg local
                    in
                    ( EditorState global nextLocal loggedInUser
                    , EditorEffect effect
                    )

                _ ->
                    ignore

        -- Search Page
        --
        SearchMessaged (Page.Search.ParentMsg myMsg) ->
            app |> update myMsg

        SearchMessaged submsg ->
            case app of
                SearchState _ local ->
                    let
                        ( nextLocal, effect ) =
                            Page.Search.update submsg local
                    in
                    ( SearchState global nextLocal
                    , SearchEffect effect
                    )

                _ ->
                    ignore

        -- Inbox Page
        --
        InboxMessaged (Page.Inbox.ParentMsg myMsg) ->
            app |> update myMsg

        InboxMessaged submsg ->
            case app of
                InboxState _ local loggedInUser ->
                    let
                        ( nextLocal, effect ) =
                            Page.Inbox.update submsg local
                    in
                    ( InboxState global nextLocal loggedInUser
                    , InboxEffect effect
                    )

                _ ->
                    ignore

        -- Register Page
        --
        RegisterMessaged (Page.Register.ParentMsg myMsg) ->
            app |> update myMsg

        RegisterMessaged submsg ->
            case app of
                RegisterState _ local ->
                    let
                        ( nextLocal, effect ) =
                            Page.Register.update submsg local
                    in
                    ( RegisterState global nextLocal
                    , RegisterEffect effect
                    )

                _ ->
                    ignore

        -- Login Page
        --
        LoginMessaged (Page.Login.ParentMsg myMsg) ->
            app |> update myMsg

        LoginMessaged submsg ->
            case app of
                LoginState _ local ->
                    let
                        ( nextLocal, effect ) =
                            Page.Login.update submsg local
                    in
                    ( LoginState global nextLocal
                    , LoginEffect effect
                    )

                _ ->
                    ignore



-- Views


view : App -> Document Msg
view app =
    let
        { session, devpro, alerts } =
            globalState app

        page =
            Page.view session devpro alerts
    in
    case app of
        RedirectState _ href ->
            Page.Redirect.view href
                |> Page.unthemed

        NotFoundState _ () ->
            Page.NotFound.view
                |> Page.unthemed

        HomeState _ () ->
            Page.Home.view
                |> page

        FeedsState _ () ->
            Page.Feeds.view ()
                |> page

        EditorState _ local _ ->
            Page.Editor.view local
                |> page

        SearchState _ local ->
            Page.Search.view local
                |> Page.map SearchMessaged
                |> page

        ToolsState _ local ->
            Page.Tools.view local
                |> page

        StarredState _ local _ ->
            Page.Starred.view local
                |> page

        InboxState _ local _ ->
            Page.Inbox.view local
                |> page

        SettingsState _ local _ ->
            Page.Settings.view AlertRequested session local
                |> Page.map SettingsMessaged
                |> page

        RegisterState _ local ->
            Page.Register.view devpro local
                |> Page.map RegisterMessaged
                |> page

        LoginState _ local ->
            Page.Login.view devpro local
                |> Page.map LoginMessaged
                |> page

        ProfileState _ local ->
            Page.Profile.view local
                |> page

        PostState _ local ->
            Page.Post.view local
                |> page

        HelpState _ () ->
            Page.Help.view ()
                |> page

        PrivacyPolicyState _ () ->
            Page.PrivacyPolicy.view ()
                |> page



-- Transitioning the App State


start : Route -> Global -> ( App, Effect )
start initRoute initGlobal =
    HomeState initGlobal ()
        |> transition initRoute


transition : Route -> App -> ( App, Effect )
transition nextRoute app =
    let
        navKey =
            Session.navKey global.session

        global =
            globalState app
    in
    {- Here, we're checking the *old state* against the *new route* to see how we should transition
       and build a new AppState. Note: `_` in first tuple position here means *coming from any
       previous state (inherently discarding previous local state; global state is available as
       `global`)*
    -}
    case ( app, nextRoute ) of
        ( _, Route.Redirect href ) ->
            ( RedirectState global href
            , Redirect href
            )

        ( _, Route.NotFound ) ->
            ( NotFoundState global ()
            , DelayEffect 3000 (PushRoute Route.Home)
            )

        ( _, Route.Home ) ->
            ( HomeState global ()
            , NoEffect
            )

        -- Feeds
        --
        ( _, Route.Feeds ) ->
            -- TODO: IMPORTANT: Create a feeds page!
            ( FeedsState global ()
            , NoEffect
            )

        -- Search
        --
        ( SearchState _ local, Route.Search maybeQuery ) ->
            ( SearchState global { local | query = maybeQuery }
            , NoEffect
            )

        ( _, Route.Search maybeQuery ) ->
            let
                ( initLocal, initEffect ) =
                    -- Initialize page state
                    Page.Search.init maybeQuery
            in
            ( SearchState global initLocal
            , SearchEffect initEffect
            )

        -- Tools
        --
        ( ToolsState _ local, Route.Tools ) ->
            -- Ignore transition
            ( ToolsState global local, NoEffect )

        ( _, Route.Tools ) ->
            let
                ( initLocal, initEffect ) =
                    -- Initialize page state
                    Page.Tools.init ()
            in
            ( ToolsState global initLocal
            , ToolsEffect initEffect
            )

        -- Post
        --
        ( _, Route.Post slug ) ->
            let
                ( initLocal, initEffect ) =
                    Page.Post.init slug
            in
            ( PostState global initLocal
            , PostEffect initEffect
            )

        -- Profile
        --
        ( ProfileState _ local, Route.Profile username ) ->
            if Page.Profile.username local == username then
                -- Ignore transition
                ( ProfileState global local, NoEffect )

            else
                let
                    maybeUser =
                        Session.user global.session

                    ( initLocal, initEffect ) =
                        -- Initialize page state
                        Page.Profile.init maybeUser username
                in
                ( ProfileState global initLocal
                , ProfileEffect initEffect
                )

        ( _, Route.Profile username ) ->
            let
                maybeUser =
                    Session.user global.session

                ( initLocal, initEffect ) =
                    -- Initialize page state
                    Page.Profile.init maybeUser username
            in
            ( ProfileState global initLocal
            , ProfileEffect initEffect
            )

        -- Help
        --
        ( _, Route.Help ) ->
            ( HelpState global ()
            , NoEffect
            )

        -- Privacy Policy
        --
        ( _, Route.PrivacyPolicy ) ->
            ( PrivacyPolicyState global ()
            , NoEffect
            )

        -- New Post
        --
        ( EditorState _ local loggedInUser, Route.NewPost ) ->
            if Page.Editor.isCreating local then
                -- Ignore transition
                ( EditorState global local loggedInUser, NoEffect )

            else
                let
                    ( initLocal, initEffect ) =
                        -- Initialize page state
                        Page.Editor.init Nothing
                in
                ( EditorState global initLocal loggedInUser
                , EditorEffect initEffect
                )

        ( _, Route.NewPost ) ->
            Session.withLoggedInUser global.session
                -- TODO: Fire off a 'Bad Permissions' alert and transition guest home or something?
                { guest = app |> transition Route.NotFound
                , loggedIn =
                    \loggedInUser ->
                        let
                            ( initLocal, initEffect ) =
                                Page.Editor.init Nothing

                            -- Initialize page state
                        in
                        ( EditorState global initLocal loggedInUser
                        , EditorEffect initEffect
                        )
                }

        -- Edit Post
        --
        ( EditorState _ local loggedInUser, Route.EditPost slug ) ->
            if not (Page.Editor.isCreating local) then
                -- Ignore transition
                ( EditorState global local loggedInUser, NoEffect )

            else
                let
                    ( initLocal, initEffect ) =
                        -- Initialize page state
                        Page.Editor.init (Just slug)
                in
                ( EditorState global initLocal loggedInUser
                , EditorEffect initEffect
                )

        ( _, Route.EditPost slug ) ->
            Session.withLoggedInUser global.session
                -- TODO: Fire off a 'Bad Permissions' alert and transition guest home or something?
                { guest = app |> transition Route.NotFound
                , loggedIn =
                    \loggedInUser ->
                        let
                            ( initState, initEffect ) =
                                -- Initialize page state
                                Page.Editor.init (Just slug)
                        in
                        ( EditorState global initState loggedInUser
                        , EditorEffect initEffect
                        )
                }

        -- Settings
        --
        ( SettingsState _ local loggedInUser, Route.Settings ) ->
            -- Ignore transition
            ( SettingsState global local loggedInUser, NoEffect )

        ( _, Route.Settings ) ->
            Session.withLoggedInUser global.session
                -- TODO: Fire off a 'Bad Permissions' alert and transition guest home or something?
                { guest = app |> transition Route.NotFound
                , loggedIn =
                    \loggedInUser ->
                        let
                            ( initLocal, initEffect ) =
                                -- Initialize page state
                                Page.Settings.init global.settings
                        in
                        ( SettingsState global initLocal loggedInUser
                        , SettingsEffect initEffect
                        )
                }

        -- Starred
        --
        ( StarredState _ local loggedInUser, Route.Starred ) ->
            -- Ignore transition
            ( StarredState global local loggedInUser, NoEffect )

        ( _, Route.Starred ) ->
            Session.withLoggedInUser global.session
                -- TODO: Fire off a 'Bad Permissions' alert and transition guest home or something?
                { guest = app |> transition Route.NotFound
                , loggedIn =
                    \loggedInUser ->
                        let
                            ( initLocal, initEffect ) =
                                -- Initialize page state
                                Page.Starred.init ()
                        in
                        ( StarredState global initLocal loggedInUser
                        , StarredEffect initEffect
                        )
                }

        -- Inbox
        --
        ( InboxState _ local loggedInUser, Route.Inbox ) ->
            -- Ignore transition
            ( InboxState global local loggedInUser, NoEffect )

        ( _, Route.Inbox ) ->
            Session.withLoggedInUser global.session
                -- TODO: Fire off a 'Bad Permissions' alert and transition guest home or something?
                { guest = app |> transition Route.NotFound
                , loggedIn =
                    \loggedInUser ->
                        let
                            ( initLocal, initEffect ) =
                                -- Initialize page state
                                Page.Inbox.init ()
                        in
                        ( InboxState global initLocal loggedInUser
                        , InboxEffect initEffect
                        )
                }

        -- Login
        --
        ( LoginState _ local, Route.Login ) ->
            -- Ignore state transition
            ( LoginState global local, NoEffect )

        ( _, Route.Login ) ->
            let
                ( initLocal, initEffect ) =
                    -- Initialize page state
                    Page.Login.init ()
            in
            Session.credentialed global.session
                -- Whoops, we're already logged in!
                { loggedIn = app |> transition Route.Home
                , guest =
                    ( LoginState global initLocal
                    , LoginEffect initEffect
                    )
                }

        ( _, Route.Logout ) ->
            Session.credentialed global.session
                -- Whoops, we're already logged out!
                { guest = app |> transition Route.Home
                , loggedIn =
                    ( HomeState { global | session = Session.new navKey Nothing } ()
                    , Effects
                        [ FireAlert Alert.loggedOut
                        , PushRoute Route.Home
                        ]
                    )
                }

        ( RegisterState _ local, Route.Register ) ->
            -- Ignore state transition
            ( RegisterState global local, NoEffect )

        ( _, Route.Register ) ->
            Session.credentialed global.session
                { loggedIn = app |> transition Route.Home
                , guest =
                    let
                        ( initLocal, initEffect ) =
                            -- Initialize page state
                            Page.Register.init ()
                    in
                    ( RegisterState global initLocal
                    , RegisterEffect initEffect
                    )
                }


updateApp : App -> Global -> App
updateApp app global =
    case app of
        RedirectState _ href ->
            RedirectState global href

        NotFoundState _ () ->
            NotFoundState global ()

        HomeState _ () ->
            HomeState global ()

        FeedsState _ () ->
            FeedsState global ()

        EditorState _ local loggedInUser ->
            EditorState global local loggedInUser

        SearchState _ local ->
            SearchState global local

        ToolsState _ local ->
            ToolsState global local

        StarredState _ local loggedInUser ->
            StarredState global local loggedInUser

        InboxState _ local loggedInUser ->
            InboxState global local loggedInUser

        SettingsState _ local loggedInUser ->
            SettingsState global local loggedInUser

        RegisterState _ local ->
            RegisterState global local

        LoginState _ local ->
            LoginState global local

        ProfileState _ local ->
            ProfileState global local

        PostState _ local ->
            PostState global local

        HelpState _ () ->
            HelpState global ()

        PrivacyPolicyState _ () ->
            PrivacyPolicyState global ()


globalState : App -> Global
globalState app =
    case app of
        RedirectState global _ ->
            global

        NotFoundState global () ->
            global

        HomeState global () ->
            global

        FeedsState global () ->
            global

        EditorState global _ _ ->
            global

        SearchState global _ ->
            global

        ToolsState global _ ->
            global

        StarredState global _ _ ->
            global

        InboxState global _ _ ->
            global

        SettingsState global _ _ ->
            global

        RegisterState global _ ->
            global

        LoginState global _ ->
            global

        ProfileState global _ ->
            global

        PostState global _ ->
            global

        HelpState global () ->
            global

        PrivacyPolicyState global () ->
            global



-- Performing Effects


perform : Nav.Key -> Effect -> Cmd Msg
perform navKey effect =
    let
        ignore =
            Cmd.none
    in
    case effect |> App.logEffect [ NoEffect, SettingsEffect Page.Settings.NoEffect ] of
        Effects effects ->
            Cmd.batch <|
                List.map (perform navKey) effects

        NoEffect ->
            ignore

        SearchEffect Page.Search.NoEffect ->
            ignore

        SettingsEffect Page.Settings.NoEffect ->
            ignore

        RegisterEffect Page.Register.NoEffect ->
            ignore

        EditorEffect Page.Editor.NoEffect ->
            ignore

        ToolsEffect Page.Tools.NoEffect ->
            ignore

        StarredEffect Page.Starred.NoEffect ->
            ignore

        InboxEffect Page.Inbox.NoEffect ->
            ignore

        LoginEffect Page.Login.NoEffect ->
            ignore

        PostEffect Page.Post.NoEffect ->
            ignore

        ProfileEffect Page.Profile.NoEffect ->
            ignore

        DelayMsg delay msg ->
            Process.sleep delay
                |> Task.perform (\_ -> msg)

        DelayEffect delay delayedEffect ->
            Process.sleep delay
                |> Task.perform (\_ -> EffectDelayed delayedEffect)

        PushRoute route ->
            Route.push navKey route

        ReplaceRoute route ->
            Route.replace navKey route

        Redirect href ->
            Nav.load href

        FireAlert alert ->
            Alert.fire AlertFired alert

        ExpireAlert alert ->
            Alert.expire 5000 AlertExpired alert

        -- Search Page
        SearchEffect Page.Search.FocusSearchbar ->
            Task.attempt (\_ -> Ignored) (Dom.focus "searchbar")

        SearchEffect (Page.Search.ReplaceQuery maybeQuery) ->
            Route.replace navKey (Route.Search maybeQuery)
