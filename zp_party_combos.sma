#include <amxmodx>
#include <colorchat>
#include <hamsandwich>
#include <zombie_plague> //Zombie Plague
//#include <zombie_escape> //Zombie Escape
#include <adv_vault>

#define PLUGIN "Party Menu"
#define VERSION "1.0"
#define AUTHOR "JkDev"

#define TAG    "[Party]"
#define ID_HUD    (taskid - TASK_HUD)
#define TASK_COMBO 5546
#define TASK_COMBOP 5546

enum (+= 77)
{
    TASK_HUD = 777,
    TASK_ACEPT
}

enum
{
    NONE = -1,
    Master,
    Start_Amount
}

enum _:pdata
{
    In_Party,
    Position,
    Amount_In_Party,
    Block_Party,
    UserName[32]
}

enum _:DataCallBack
{
    MASTER,
    USER
}

new g_PartyData[33][pdata], Array:Party_Ids[33], g_maxplayers, g_MenuCallback[DataCallBack], g_MsgSayText

new cvar_time_acept, cvar_max_players, cvar_allow_bots
new g_combo[33], g_damage[33], g_Hits[33] // Combos Agregados
new g_combop[33], g_damagep[33], g_Hitsp[33] // Combos Party Agregados
new g_type, g_enabled, g_recieved, bool:g_showrecieved, g_hudmsg1, g_hudmsg2 // Bullet Dmg, Mysing Combo

public plugin_natives()
{
    //register_native("ze_open_party_menu", "native_ze_open_party_menu", 1) // Zombie Escape
    register_native("zp_open_party_menu", "native_zp_open_party_menu", 1) // Zombie Plague
}


public plugin_init()
{

    register_plugin(PLUGIN, VERSION, AUTHOR)

    // Event
    register_event("Damage", "on_damage", "b", "2!0", "3=0", "4!0")
    register_event("HLTV", "on_new_round", "a", "1=0", "2=0")#include <amxmodx>
#include <colorchat>
#include <hamsandwich>
#include <zombie_plague> //Zombie Plague
//#include <zombie_escape> //Zombie Escape
#include <adv_vault>

#define PLUGIN "Party Menu"
#define VERSION "1.0"
#define AUTHOR "JkDev"

#define TAG    "[Party]"
#define ID_HUD    (taskid - TASK_HUD)
#define TASK_COMBO 5546
#define TASK_COMBOP 5546

enum (+= 77)
{
    TASK_HUD = 777,
    TASK_ACEPT
}

enum
{
    NONE = -1,
    Master,
    Start_Amount
}

enum _:pdata
{
    In_Party,
    Position,
    Amount_In_Party,
    Block_Party,
    UserName[32]
}

enum _:DataCallBack
{
    MASTER,
    USER
}

new g_PartyData[33][pdata], Array:Party_Ids[33], g_maxplayers, g_MenuCallback[DataCallBack], g_MsgSayText

new cvar_time_acept, cvar_max_players, cvar_allow_bots
new g_combo[33], g_damage[33], g_Hits[33] // Combos Agregados
new g_combop[33], g_damagep[33], g_Hitsp[33] // Combos Party Agregados
new g_type, g_enabled, g_recieved, bool:g_showrecieved, g_hudmsg1, g_hudmsg2 // Bullet Dmg, Mysing Combo

public plugin_natives()
{
    //register_native("ze_open_p_menu", "native_ze_open_p_menu", 1) // Zombie Escape
    register_native("zp_open_p_menu", "native_zp_open_p_menu", 1) // Zombie Plague
}


public plugin_init()
{

    register_plugin(PLUGIN, VERSION, AUTHOR)

    // Event
    register_event("Damage", "on_damage", "b", "2!0", "3=0", "4!0")
    register_event("HLTV", "on_new_round", "a", "1=0", "2=0")
    register_event("HLTV","event_newround", "a","1=0", "2=0")

    g_type = register_cvar("amx_bulletdamage","1")
    g_recieved = register_cvar("amx_bulletdamage_recieved","1")

    register_clcmd("say /party", "cmdParty")
    register_clcmd("say_team", "cmdSayTeam")

    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")

    cvar_time_acept = register_cvar("party_time_acept","15")
    cvar_max_players = register_cvar("party_max_players","3")
    cvar_allow_bots = register_cvar("party_allow_bots","0")

    g_hudmsg1 = CreateHudSyncObj()
    g_hudmsg2= CreateHudSyncObj()

    g_maxplayers = get_maxplayers()
    g_MsgSayText = get_user_msgid("SayText")

    g_MenuCallback[MASTER] = menu_makecallback("check_master")
    g_MenuCallback[USER] = menu_makecallback("check_user")
}

public event_newround()
{
    for(new player = 0; player <= 32; player++)
    {
        g_combo[player] = g_combop[player] = 1
        g_damage[player] = g_damagep[player] = 0
        g_Hits[player] = g_Hitsp[player] = 0
    }
}

public plugin_cfg()
    for(new i = 1; i <= g_maxplayers; i++)
        Party_Ids[i] = ArrayCreate(1, 1)

public client_connect(id)
{
    g_combo[id] = g_combop[id] = 1
    g_damage[id] = g_damagep[id] = 0
    g_Hits[id] = g_Hitsp[id] = 0
}
public client_disconnected(id)
{
    if(g_PartyData[id][In_Party])
        g_PartyData[id][Position] ? g_PartyData[id][Amount_In_Party] == 2 ? destoy_party(id) : remove_party_user(id) : destoy_party(id)

    g_PartyData[id][UserName][0] = 0
    g_PartyData[id][Block_Party] = false
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
    // Attacker is human...
    //if (!ze_is_user_zombie(attacker)) Quita el comentario si es para ZE
    if (!zp_get_user_zombie(attacker))
    {
        if(!g_PartyData[attacker][In_Party]) // Combos Sin Party
        {
            // Combos Agregados
            g_damage[attacker] += floatround(damage)
            g_Hits[attacker]++
            while(g_damage[attacker]>=(power(g_combo[attacker], 1)*330))
            {
                g_combo[attacker]++
            }
            remove_task(attacker+TASK_COMBO)
            set_task(0.1, "task_combo", attacker+TASK_COMBO)
            set_task(4.0, "rcombo", attacker+TASK_COMBO)
        }
        else // Combos Del Party
        {
            new Players[32], user
            get_party_index(attacker, Players)
            for(new i; i < g_PartyData[attacker][Amount_In_Party]; i++)
            {
                user = Players[i]
                g_damagep[user] += floatround(damage) / g_PartyData[user][Amount_In_Party]
                g_Hitsp[user]++
                while(g_damagep[user]>=(power(g_combop[user], 1)*430))
                {
                    g_combop[user]++
                }
                remove_task(user+TASK_COMBOP)
                set_task(0.1, "tparty_c", user+TASK_COMBOP)
                set_task(4.0, "rparty_c", user+TASK_COMBOP)
            }
        }
    }
}

public on_new_round()
{
    g_enabled = get_pcvar_num(g_type)
    if(get_pcvar_num(g_recieved)) g_showrecieved = true
}

public on_damage(id)
{
    if(g_enabled)
    {
        static damage; damage = read_data(2)
        //if(g_showrecieved && ze_is_user_zombie(id)) // Zombie Escape
        if(g_showrecieved && zp_get_user_zombie(id)) //Zombie Plague
        {
            set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1)
            ShowSyncHudMsg(id, g_hudmsg2, "[DaÃ±o]= %i^n", damage)
        }
    }
}

public task_combo(attacker)
{
    attacker -= TASK_COMBO
    static flags
    flags = get_user_flags(attacker)

    if(g_combo[attacker]>0)
    {
        set_hudmessage(0, 200, 200, -1.0, 0.6, 1, 0.1, 4.0, 0.01, 0.01, -1)
        ShowSyncHudMsg(attacker, g_hudmsg1, "Combos Normales^nHits: %d | Damage: %d^n%d | %d^nTotal de Combos: %d^nTu Ganas: %d AmmoPacks", //Zombie Plague
        //ShowSyncHudMsg(attacker, g_hudmsg1, "Combos Normales^nHits: %d | Damage: %d^n%d | %d^nTotal de Combos: %d^nTu Ganas: %d Escape Coins", //Zombie Escape
        g_Hits[attacker], g_damage[attacker], g_damage[attacker], (power(g_combo[attacker], 1)*330), g_combo[attacker], g_combo[attacker] * 6+((flags & ADMIN_LEVEL_D ? 7: flags & ADMIN_LEVEL_A ? 5: flags & ADMIN_LEVEL_B ? 3 : 0)))
    }
}
public tparty_c(i)
{
    i -= TASK_COMBOP

    static flags
    flags = get_user_flags(i)

    //if(g_combop[i]>0 && !ze_is_user_zombie(i) && is_user_alive(i)) //Zombie Escape
    if(g_combop[i]>0 && !zp_get_user_zombie(i) && is_user_alive(i)) //Zombie Plague
    {
        if(g_PartyData[i][In_Party])
        {
            set_hudmessage(0, 200, 200, -1.0, 0.6, 1, 0.1, 4.0, 0.01, 0.01, -1)
            //ShowSyncHudMsg(i, g_hudmsg1, "Combo de la Party^nHits: %d | Damage: %d^n%d | %d^nTotal de Combos: %d^nTu Ganas: %d Ammo Packs", //Zombie Escape
            ShowSyncHudMsg(i, g_hudmsg1, "Combo de la Party^nHits: %d | Damage: %d^n%d | %d^nTotal de Combos: %d^nTu Ganas: %d Ammo Packs", //Zombie Plague
            g_Hitsp[i], g_damagep[i], g_damagep[i], (power(g_combop[i], 1)*430), g_combop[i], g_combop[i] * 4+((flags & ADMIN_LEVEL_D ? 7: flags & ADMIN_LEVEL_A ? 5: flags & ADMIN_LEVEL_B ? 3 : 0)))
        }
    }
}

public rcombo(id)
{
    id -= TASK_COMBO
    static flags
    flags = get_user_flags(id)

    static ganancia; ganancia = g_combo[id] * 6+((flags & ADMIN_LEVEL_D ? 7: flags & ADMIN_LEVEL_A ? 5: flags & ADMIN_LEVEL_B ? 3 : 0))
    if (g_combo[id]>0)
    {
        set_hudmessage(120, 120, 120, -1.0, 0.25, 0, 0.1, 4.0, 0.01, 0.01, -1)
        //ShowSyncHudMsg(id, g_hudmsg1, "^n^n^n^n Combo Terminado (%d)^nGanancia: %d Escape Coins", g_combo[id], ganancia) //Zombie Escape
        ShowSyncHudMsg(id, g_hudmsg1, "^n^n^n^n Combo Terminado (%d)^nGanancia: %d Ammo Packs", g_combo[id], ganancia) //Zombie Plague
        ColorChat(id, TEAM_COLOR, "^x04[ZP AG]^x01 Combo Total:^x04 %d^x01 | Damage Total:^x04 %d^x01 | Hits Echos:^x04 %d^x01 | Ganancia:^x04 %d", g_combo[id], g_damage[id], g_Hits[id], ganancia)
        //ze_set_escape_coins(id, ze_get_escape_coins(id) + ganancia)// //Zombie Escape
        set_user_ammo_packs(id, get_user_ammo_packs(id) + ganancia) //Zombie Plague
    }

    g_damage[id] = 0
    g_Hits[id] = 0
    g_combo[id] = 0
}
public rparty_c(i)
{

    i -= TASK_COMBOP
    static flags
    flags = get_user_flags(i)

    static gananciap; gananciap = g_combop[i] * 4+((flags & ADMIN_LEVEL_D ? 7: flags & ADMIN_LEVEL_A ? 5: flags & ADMIN_LEVEL_B ? 3 : 0))
    if(g_PartyData[i][In_Party])
    {
        //if(!ze_is_user_zombie(i)) //Zombie Escape
        if(!zp_get_user_zombie(i)) //Zombie Plague
        {
            set_hudmessage(120, 120, 120, -1.0, 0.25, 0, 0.1, 4.0, 0.01, 0.01, -1)
            //ShowSyncHudMsg(i, g_hudmsg1, "^n^n^n^n Combo Party Terminado (%d)^nGanancia: %d Escape Coins", g_combop[i], gananciap) //Zombie Escape
            ShowSyncHudMsg(i, g_hudmsg1, "^n^n^n^n Combo Party Terminado (%d)^nGanancia: %d Ammo Packs", g_combop[i], gananciap) //Zombie Plague
            ColorChat(i, TEAM_COLOR, "^x04[ZP AG]^x01 Combo party Total:^x04 %d^x01 | Damage Total:^x04 %d^x01 | Hits Echos:^x04 %d^x01 | Ganancia:^x04 %d", g_combop[i], g_damagep[i], g_Hitsp[i], gananciap)
        }
        //ze_set_escape_coins(i, ze_get_escape_coins(i) + gananciap) //Zombie Escape
        set_user_ammo_packs(id, get_user_ammo_packs(id) + ganancia) //Zombie Plague
    }

    g_damagep[i] = 0
    g_Hitsp[i] = 0
    g_combop[i] = 0
}

public cmdParty(id)
{

    if(g_PartyData[id][In_Party])
        mparty_infmenu(id)
    else
        mp_menu(id)

    return PLUGIN_HANDLED
}

public mp_menu(id) {

    new iMenu = menu_create("[ZP] \rMenu Party:","p_menu"), BlockParty[50]

    menu_additem(iMenu, "\yCrear Party", "0")

    formatex(BlockParty, charsmax(BlockParty), "\yBloquear Invitaciones De Party: \w%s",g_PartyData[id][Block_Party] ? "Si" : "No")

    menu_additem(iMenu, BlockParty, "1")

    menu_setprop(iMenu, MPROP_EXITNAME, "Salir")
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

    menu_display(id, iMenu, 0)
}

public mparty_infmenu(id) {

    new iMenu = menu_create("[ZP] \rMenu Party:","p_infmenu")

    menu_additem(iMenu, "Agregar Integrante", .callback = g_MenuCallback[MASTER])
    menu_additem(iMenu, "Expulsar Integrande", .callback = g_MenuCallback[MASTER])
    menu_additem(iMenu, "Destruir Party", .callback = g_MenuCallback[MASTER])
    menu_additem(iMenu, "Salir del Party", .callback = g_MenuCallback[USER])

    menu_setprop(iMenu, MPROP_EXITNAME, "Salir")
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

    menu_display(id, iMenu)
}

public mparty_addmenu(id) {

    new iMenu = menu_create(g_PartyData[id][In_Party] ? "\rAgregar Integrante:" : "\rCrear Party:", "p_createmenu"), Poss[3], Name[32]

    for(new i = 1; i <= g_maxplayers; i++) {

        if(!is_available_to_party(i) || id == i)
            continue;

        get_user_name(i, Name, charsmax(Name))
        num_to_str(i, Poss, charsmax(Poss))
        menu_additem(iMenu, Name, Poss)
    }

    menu_setprop(iMenu, MPROP_EXITNAME, "Salir")
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

    menu_display(id, iMenu)
}

public mparty_kickmenu(id) {

    new iMenu = menu_create("\rKick Party Menu:","p_kickmenu"), Players[32], Poss[3], user

    get_party_index(id, Players)

    for(new i; i < g_PartyData[id][Amount_In_Party]; i++) {
        user = Players[i]
        num_to_str(user, Poss, charsmax(Poss))
        menu_additem(iMenu, g_PartyData[user][UserName], Poss)
    }

    menu_setprop(iMenu, MPROP_EXITNAME, "Salir")

    menu_display(id, iMenu)
}

public mparty_invitemenu(id2, MasterId) {

    new MenuTitle[128], iMenu, Str_MasterId[3]

    set_player_party_name(MasterId)
    set_player_party_name(id2)

    client_print(MasterId, print_chat, "%s Solicitud enviada a %s", TAG, g_PartyData[id2][UserName])

    formatex(MenuTitle, charsmax(MenuTitle), "%s te mando una invitacion para %s Party", g_PartyData[MasterId][UserName], g_PartyData[MasterId][In_Party] ? "unirte al" : "crear un")

    new UserTaskArgs[3]

    UserTaskArgs[0] = iMenu = menu_create( MenuTitle , "p_invitemenu")
    UserTaskArgs[1] = MasterId

    num_to_str(MasterId, Str_MasterId, charsmax(Str_MasterId))

    menu_additem( iMenu , "Aceptar", Str_MasterId)
    menu_additem( iMenu , "Rechazar", Str_MasterId)

    if(is_user_bot(id2) && get_pcvar_num(cvar_allow_bots)) {
        p_invitemenu(id2, iMenu, 0)
        return
    }

    menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER)

    menu_display(id2, iMenu)

    remove_task_acept(id2)

    set_task(get_pcvar_float(cvar_time_acept), "Time_Acept", id2+TASK_ACEPT, UserTaskArgs, 2)
}


public p_menu(id, menu, item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return
    }

    if(item) {
        g_PartyData[id][Block_Party] = g_PartyData[id][Block_Party] ? false : true
        mp_menu(id)
    }
    else
        mparty_addmenu(id)

    menu_destroy(menu)

}

public p_createmenu(id, menu, item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return
    }

    new iKey[6], iAccess, iCallback, id2

    menu_item_getinfo(menu, item, iAccess, iKey, charsmax(iKey), _, _, iCallback)

    id2 = str_to_num(iKey)

    if(!is_available_to_party(id2))
        return

    mparty_invitemenu(id2, id)

    menu_destroy(menu)
}

public p_invitemenu(id, menu, item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        remove_task_acept(id)
        return
    }

    new iKey[6], iAccess, iCallback, id_master

    menu_item_getinfo(menu, item, iAccess, iKey, charsmax(iKey), _, _, iCallback)

    id_master = str_to_num(iKey)

    switch(item) {
        case 0: {

            if(!g_PartyData[id_master][In_Party]) {
                create_party(id_master, id)
                set_task_party_hud(id_master)
                set_task_party_hud(id)
            }
            else {
                if(g_PartyData[id_master][Amount_In_Party] == get_pcvar_num(cvar_max_players)) {

                    client_print(id, print_chat, "%s Ya se alcanzo el numero maximo de integrantes en la party", TAG)
                    client_print(id_master, print_chat, "%s Ya alcanzaste el numero maximo de integrantes en la party", TAG)

                    remove_task_acept(id)

                    menu_destroy(menu)
                    return
                }

                add_party_user(id_master, id)
                set_task_party_hud(id)
            }

            client_print(id_master, print_chat, "%s %s fue agregado al Party", TAG, g_PartyData[id][UserName])
        }
        case 1: client_print(id_master, print_chat, "%s %s cancelo la invitacion de Party", TAG, g_PartyData[id][UserName])
    }

    remove_task_acept(id)

    menu_destroy(menu)
}

public p_kickmenu(id, menu, item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return
    }

    new iKey[6], iAccess, iCallback, id2

    menu_item_getinfo(menu, item, iAccess, iKey, charsmax(iKey), _, _, iCallback)

    id2 = str_to_num(iKey)

    if(is_user_connected(id2))
        g_PartyData[id][Amount_In_Party] == 2 ? destoy_party(id) : remove_party_user(id2)

    menu_destroy(menu)
}

public p_infmenu(id, menu,item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return
    }

    switch(item) {
        case 0: {
            if(g_PartyData[id][Amount_In_Party] < get_pcvar_num(cvar_max_players))
                mparty_addmenu(id)
            else
                client_print(id, print_chat, "%s Ya alcanzaste el numero maximo de integrantes en la party", TAG)
        }
        case 1: mparty_kickmenu(id)
        case 2: destoy_party(id)
        case 3: remove_party_user(id)
    }

    menu_destroy(menu)
}

public PartyHud(taskid) {

    static id
    id = ID_HUD

    if(!is_user_connected(id)) {
        remove_task(taskid)
        return
    }

    static CountParty, PartyMsg[256], Players[32], id2

    CountParty = 0
    PartyMsg[0] = 0

    get_party_index(id, Players)
    for(new i; i < g_PartyData[id][Amount_In_Party]; i++) {

        id2 = Players[i]

        if(CountParty)
            add(PartyMsg, charsmax(PartyMsg), "^n")

        format(PartyMsg, charsmax(PartyMsg), "%s%s", strlen(PartyMsg) ? PartyMsg : "^t^t^tMiembros del Party^n", g_PartyData[id2][UserName])
        CountParty++
    }

    set_hudmessage(255, 255, 255, 0.75, 0.34, 0, 6.0, 1.0);
    show_hudmessage(id, PartyMsg)
}

public Time_Acept(UserTaskArgs[], taskid) {

    taskid -= TASK_ACEPT;

    if(!g_PartyData[taskid][In_Party]) {

        client_print(UserTaskArgs[1], print_chat, "%s %s cancelo la invitacion de party", TAG, g_PartyData[taskid][UserName])
        menu_destroy(UserTaskArgs[0])
        show_menu(taskid, 0, "^n", 1)
    }
}

stock create_party(master, guest) {

    set_party_member(master, master)
    set_party_member(master, guest)
    set_party_member(guest, master)
    set_party_member(guest, guest)

    set_party_vars(master, Start_Amount)
    set_party_vars(guest, ++g_PartyData[master][Amount_In_Party])
}

stock add_party_user(master, guest) {

    new Players[32], member, amount = g_PartyData[master][Amount_In_Party]

    get_party_index(master, Players)

    for(new i; i < amount; i++) {

        member = Players[i]

        set_party_member(guest, member)
        set_party_member(member, guest)
        g_PartyData[member][Amount_In_Party]++

    }

    set_party_member(guest, guest)
    set_party_vars(guest, amount+1)
}

stock set_party_member(id, id2)
    ArrayPushCell(Party_Ids[id], id2)

stock set_party_vars(id, amount) {

    g_PartyData[id][In_Party] = true
    g_PartyData[id][Position] = amount-1
    g_PartyData[id][Amount_In_Party] = amount

}

stock destoy_party(id) {

    new Players[32], id2, Amount = g_PartyData[id][Amount_In_Party]
    get_party_index(id, Players)

    for(new i; i < Amount; i++) {
        id2 = Players[i]
        clear_party_user(id2)
        client_print(id2, print_chat, "%s La party fue destruida", TAG)

    }
}

stock remove_party_user(user) {

    new Players[32], id, Amount = g_PartyData[user][Amount_In_Party]

    get_party_index(user, Players)

    clear_party_user(user)

    for(new i; i < Amount; i++) {

        id = Players[i]

        if(id != user) {

            ArrayClear(Party_Ids[id])

            for(new z; z < Amount; z++)
                if(Players[z] != user)
                    set_party_member(id, Players[z])

            g_PartyData[id][Position] = i
            g_PartyData[id][Amount_In_Party] = Amount-1
            client_print(id, print_chat, "%s %s salio del party", TAG, g_PartyData[user][UserName])
        }
    }
}

stock clear_party_user(id) {

    ArrayClear(Party_Ids[id])
    g_PartyData[id][In_Party] = false
    g_PartyData[id][Position] = NONE
    g_PartyData[id][Amount_In_Party] = NONE
    remove_task_party_hud(id)

}

stock set_task_party_hud(id)
    set_task(1.0, "PartyHud", id+TASK_HUD, _, _, "b")

stock remove_task_party_hud(id)
    remove_task(id+TASK_HUD)

stock remove_task_acept(id)
    if(task_exists(id+TASK_ACEPT))
        remove_task(id+TASK_ACEPT)


stock set_player_party_name(id) {

    if(g_PartyData[id][UserName][0])
        return 0

    get_user_name(id, g_PartyData[id][UserName], charsmax(g_PartyData[][UserName]))

    return 1
}

stock is_available_to_party(id) {

    if(!is_user_connected(id) || g_PartyData[id][In_Party] || g_PartyData[id][Block_Party])
        return false

    return true
}

stock get_party_index(id, players[]) {

    for(new i; i < g_PartyData[id][Amount_In_Party]; i++)
        players[i] = ArrayGetCell(Party_Ids[id], i)

    return players[0] ? 1 : 0
}

public check_master(id)
    return g_PartyData[id][Position] ? ITEM_DISABLED : ITEM_ENABLED

public check_user(id)
    return g_PartyData[id][Position] ? ITEM_ENABLED : ITEM_DISABLED

public cmdSayTeam(id) {

    static Text[192]
    read_args(Text, charsmax(Text))
    remove_quotes(Text)

    replace_all(Text, charsmax(Text), "%", "")

    if(!ValidMessage(Text) || !g_PartyData[id][In_Party]) {

        client_print(id, print_chat,"%s Tu Mensaje es invalido o no te encuentras en un Party", TAG)
        return PLUGIN_HANDLED;
    }

    static Message[192], Players[32], id2, Amount
    Amount = g_PartyData[id][Amount_In_Party]

    get_party_index(id, Players)

    formatex(Message, charsmax(Message), "^x04%s ^x03%s^x01 : %s", TAG, g_PartyData[id][UserName], Text)

    for(new i; i < Amount; i++) {

        id2 = Players[i]

        message_begin(MSG_ONE_UNRELIABLE, g_MsgSayText, _, id2)
        write_byte(id)
        write_string(Message)
        message_end()
    }

    return PLUGIN_HANDLED;
}

ValidMessage(text[]) {
    static len, i
    len = strlen(text)

    if(!len)
        return false

    for(i = 0; i < len; i++) {
        if( text[i] != ' ' ) {
            return true
        }
    }

    return false
}

//public native_ze_open_p_menu(id) //Zombie Esacpe
public native_zp_open_p_menu(id) //Zombie Plague
{
    if (!is_user_connected(id))
    {
        log_error(AMX_ERR_NATIVE, "[ZP AG] Invalid Player (%d)", id)
        return false
    }

    mp_menu(id)
    return true
}

    register_event("HLTV","event_newround", "a","1=0", "2=0")

    g_type = register_cvar("amx_bulletdamage","1")
    g_recieved = register_cvar("amx_bulletdamage_recieved","1")

    register_clcmd("say /party", "cmdParty")
    register_clcmd("say_team", "cmdSayTeam")

    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")

    cvar_time_acept = register_cvar("party_time_acept","15")
    cvar_max_players = register_cvar("party_max_players","3")
    cvar_allow_bots = register_cvar("party_allow_bots","0")

    g_hudmsg1 = CreateHudSyncObj()
    g_hudmsg2= CreateHudSyncObj()

    g_maxplayers = get_maxplayers()
    g_MsgSayText = get_user_msgid("SayText")

    g_MenuCallback[MASTER] = menu_makecallback("check_master")
    g_MenuCallback[USER] = menu_makecallback("check_user")
}

public event_newround()
{
    for(new player = 0; player <= 32; player++)
    {
        g_combo[player] = g_combop[player] = 1
        g_damage[player] = g_damagep[player] = 0
        g_Hits[player] = g_Hitsp[player] = 0
    }
}

public plugin_cfg()
    for(new i = 1; i <= g_maxplayers; i++)
        Party_Ids[i] = ArrayCreate(1, 1)

public client_connect(id)
{
    g_combo[id] = g_combop[id] = 1
    g_damage[id] = g_damagep[id] = 0
    g_Hits[id] = g_Hitsp[id] = 0
}
public client_disconnected(id)
{
    if(g_PartyData[id][In_Party])
        g_PartyData[id][Position] ? g_PartyData[id][Amount_In_Party] == 2 ? destoy_party(id) : remove_party_user(id) : destoy_party(id)

    g_PartyData[id][UserName][0] = 0
    g_PartyData[id][Block_Party] = false
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
    // Attacker is human...
    //if (!ze_is_user_zombie(attacker)) Quita el comentario si es para ZE
    if (!zp_get_user_zombie(attacker))
    {
        if(!g_PartyData[attacker][In_Party]) // Combos Sin Party
        {
            // Combos Agregados
            g_damage[attacker] += floatround(damage)
            g_Hits[attacker]++
            while(g_damage[attacker]>=(power(g_combo[attacker], 1)*330))
            {
                g_combo[attacker]++
            }
            remove_task(attacker+TASK_COMBO)
            set_task(0.1, "task_combo", attacker+TASK_COMBO)
            set_task(4.0, "reset_combo", attacker+TASK_COMBO)
        }
        else // Combos Del Party
        {
            new Players[32], user
            get_party_index(attacker, Players)
            for(new i; i < g_PartyData[attacker][Amount_In_Party]; i++)
            {
                user = Players[i]
                g_damagep[user] += floatround(damage) / g_PartyData[user][Amount_In_Party]
                g_Hitsp[user]++
                while(g_damagep[user]>=(power(g_combop[user], 1)*430))
                {
                    g_combop[user]++
                }
                remove_task(user+TASK_COMBOP)
                set_task(0.1, "task_party_combo", user+TASK_COMBOP)
                set_task(4.0, "reset_party_combo", user+TASK_COMBOP)
            }
        }
    }
}

public on_new_round()
{
    g_enabled = get_pcvar_num(g_type)
    if(get_pcvar_num(g_recieved)) g_showrecieved = true
}

public on_damage(id)
{
    if(g_enabled)
    {
        static damage; damage = read_data(2)
        //if(g_showrecieved && ze_is_user_zombie(id)) // Zombie Escape
        if(g_showrecieved && zp_get_user_zombie(id)) //Zombie Plague
        {
            set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1)
            ShowSyncHudMsg(id, g_hudmsg2, "[DaÃ±o]= %i^n", damage)
        }
    }
}

public task_combo(attacker)
{
    attacker -= TASK_COMBO
    static flags
    flags = get_user_flags(attacker)

    if(g_combo[attacker]>0)
    {
        set_hudmessage(0, 200, 200, -1.0, 0.6, 1, 0.1, 4.0, 0.01, 0.01, -1)
        ShowSyncHudMsg(attacker, g_hudmsg1, "Combos Normales^nHits: %d | Damage: %d^n%d | %d^nTotal de Combos: %d^nTu Ganas: %d AmmoPacks", //Zombie Plague
        //ShowSyncHudMsg(attacker, g_hudmsg1, "Combos Normales^nHits: %d | Damage: %d^n%d | %d^nTotal de Combos: %d^nTu Ganas: %d Escape Coins", //Zombie Escape
        g_Hits[attacker], g_damage[attacker], g_damage[attacker], (power(g_combo[attacker], 1)*330), g_combo[attacker], g_combo[attacker] * 6+((flags & ADMIN_LEVEL_D ? 7: flags & ADMIN_LEVEL_A ? 5: flags & ADMIN_LEVEL_B ? 3 : 0)))
    }
}
public task_party_combo(i)
{
    i -= TASK_COMBOP

    static flags
    flags = get_user_flags(i)

    //if(g_combop[i]>0 && !ze_is_user_zombie(i) && is_user_alive(i)) //Zombie Escape
    if(g_combop[i]>0 && !zp_get_user_zombie(i) && is_user_alive(i)) //Zombie Plague
    {
        if(g_PartyData[i][In_Party])
        {
            set_hudmessage(0, 200, 200, -1.0, 0.6, 1, 0.1, 4.0, 0.01, 0.01, -1)
            //ShowSyncHudMsg(i, g_hudmsg1, "Combo de la Party^nHits: %d | Damage: %d^n%d | %d^nTotal de Combos: %d^nTu Ganas: %d Ammo Packs", //Zombie Escape
            ShowSyncHudMsg(i, g_hudmsg1, "Combo de la Party^nHits: %d | Damage: %d^n%d | %d^nTotal de Combos: %d^nTu Ganas: %d Ammo Packs", //Zombie Plague
            g_Hitsp[i], g_damagep[i], g_damagep[i], (power(g_combop[i], 1)*430), g_combop[i], g_combop[i] * 4+((flags & ADMIN_LEVEL_D ? 7: flags & ADMIN_LEVEL_A ? 5: flags & ADMIN_LEVEL_B ? 3 : 0)))
        }
    }
}

public reset_combo(id)
{
    id -= TASK_COMBO
    static flags
    flags = get_user_flags(id)

    static ganancia; ganancia = g_combo[id] * 6+((flags & ADMIN_LEVEL_D ? 7: flags & ADMIN_LEVEL_A ? 5: flags & ADMIN_LEVEL_B ? 3 : 0))
    if (g_combo[id]>0)
    {
        set_hudmessage(120, 120, 120, -1.0, 0.25, 0, 0.1, 4.0, 0.01, 0.01, -1)
        ShowSyncHudMsg(id, g_hudmsg1, "^n^n^n^n Combo Terminado (%d)^nGanancia: %d Escape Coins", g_combo[id], ganancia)
        ColorChat(id, TEAM_COLOR, "^x04[ZP AG]^x01 Combo Total:^x04 %d^x01 | Damage Total:^x04 %d^x01 | Hits Echos:^x04 %d^x01 | Ganancia:^x04 %d", g_combo[id], g_damage[id], g_Hits[id], ganancia)
        //ze_set_escape_coins(id, ze_get_escape_coins(id) + ganancia)// //Zombie Escape
        setExp(id, get_pcvar_num(id) + ganancia) //Zombie Plague
    }

    g_damage[id] = 0
    g_Hits[id] = 0
    g_combo[id] = 0
}
public reset_party_combo(i)
{

    i -= TASK_COMBOP
    static flags
    flags = get_user_flags(i)

    static gananciap; gananciap = g_combop[i] * 4+((flags & ADMIN_LEVEL_D ? 7: flags & ADMIN_LEVEL_A ? 5: flags & ADMIN_LEVEL_B ? 3 : 0))
    if(g_PartyData[i][In_Party])
    {
        //if(!ze_is_user_zombie(i)) //Quitar comentario si es para ZE
        if(!zp_get_user_zombie(i))
        {
            set_hudmessage(120, 120, 120, -1.0, 0.25, 0, 0.1, 4.0, 0.01, 0.01, -1)
            ShowSyncHudMsg(i, g_hudmsg1, "^n^n^n^n Combo Party Terminado (%d)^nGanancia: %d Escape Coins", g_combop[i], gananciap)
            ColorChat(i, TEAM_COLOR, "^x04[ZP AG]^x01 Combo party Total:^x04 %d^x01 | Damage Total:^x04 %d^x01 | Hits Echos:^x04 %d^x01 | Ganancia:^x04 %d", g_combop[i], g_damagep[i], g_Hitsp[i], gananciap)
        }
        //ze_set_escape_coins(i, ze_get_escape_coins(i) + gananciap) //Quitar comentario si es para ZE
        setExp(i, get_pcvar_num(i) + gananciap)
    }

    g_damagep[i] = 0
    g_Hitsp[i] = 0
    g_combop[i] = 0
}

public cmdParty(id)
{

    if(g_PartyData[id][In_Party])
        show_party_info_menu(id)
    else
        show_party_menu(id)

    return PLUGIN_HANDLED
}

public show_party_menu(id) {

    new iMenu = menu_create("[ZP AG] \rMenu Party:","party_menu"), BlockParty[50]

    menu_additem(iMenu, "\yCrear Party", "0")

    formatex(BlockParty, charsmax(BlockParty), "\yBloquear Invitaciones De Party: \w%s",g_PartyData[id][Block_Party] ? "Si" : "No")

    menu_additem(iMenu, BlockParty, "1")

    menu_setprop(iMenu, MPROP_EXITNAME, "Salir")
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

    menu_display(id, iMenu, 0)
}

public show_party_info_menu(id) {

    new iMenu = menu_create("[ZP AG] \rMenu Party:","party_info_menu")

    menu_additem(iMenu, "Agregar Integrante", .callback = g_MenuCallback[MASTER])
    menu_additem(iMenu, "Expulsar Integrande", .callback = g_MenuCallback[MASTER])
    menu_additem(iMenu, "Destruir Party", .callback = g_MenuCallback[MASTER])
    menu_additem(iMenu, "Salir del Party", .callback = g_MenuCallback[USER])

    menu_setprop(iMenu, MPROP_EXITNAME, "Salir")
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

    menu_display(id, iMenu)
}

public show_party_add_menu(id) {

    new iMenu = menu_create(g_PartyData[id][In_Party] ? "\rAgregar Integrante:" : "\rCrear Party:", "party_create_menu"), Poss[3], Name[32]

    for(new i = 1; i <= g_maxplayers; i++) {

        if(!is_available_to_party(i) || id == i)
            continue;

        get_user_name(i, Name, charsmax(Name))
        num_to_str(i, Poss, charsmax(Poss))
        menu_additem(iMenu, Name, Poss)
    }

    menu_setprop(iMenu, MPROP_EXITNAME, "Salir")
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)

    menu_display(id, iMenu)
}

public show_party_kick_menu(id) {

    new iMenu = menu_create("\rKick Party Menu:","party_kick_menu"), Players[32], Poss[3], user

    get_party_index(id, Players)

    for(new i; i < g_PartyData[id][Amount_In_Party]; i++) {
        user = Players[i]
        num_to_str(user, Poss, charsmax(Poss))
        menu_additem(iMenu, g_PartyData[user][UserName], Poss)
    }

    menu_setprop(iMenu, MPROP_EXITNAME, "Salir")

    menu_display(id, iMenu)
}

public show_party_invite_menu(id2, MasterId) {

    new MenuTitle[128], iMenu, Str_MasterId[3]

    set_player_party_name(MasterId)
    set_player_party_name(id2)

    client_print(MasterId, print_chat, "%s Solicitud enviada a %s", TAG, g_PartyData[id2][UserName])

    formatex(MenuTitle, charsmax(MenuTitle), "%s te mando una invitacion para %s Party", g_PartyData[MasterId][UserName], g_PartyData[MasterId][In_Party] ? "unirte al" : "crear un")

    new UserTaskArgs[3]

    UserTaskArgs[0] = iMenu = menu_create( MenuTitle , "party_invite_menu")
    UserTaskArgs[1] = MasterId

    num_to_str(MasterId, Str_MasterId, charsmax(Str_MasterId))

    menu_additem( iMenu , "Aceptar", Str_MasterId)
    menu_additem( iMenu , "Rechazar", Str_MasterId)

    if(is_user_bot(id2) && get_pcvar_num(cvar_allow_bots)) {
        party_invite_menu(id2, iMenu, 0)
        return
    }

    menu_setprop(iMenu, MPROP_EXIT, MEXIT_NEVER)

    menu_display(id2, iMenu)

    remove_task_acept(id2)

    set_task(get_pcvar_float(cvar_time_acept), "Time_Acept", id2+TASK_ACEPT, UserTaskArgs, 2)
}


public party_menu(id, menu, item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return
    }

    if(item) {
        g_PartyData[id][Block_Party] = g_PartyData[id][Block_Party] ? false : true
        show_party_menu(id)
    }
    else
        show_party_add_menu(id)

    menu_destroy(menu)

}

public party_create_menu(id, menu, item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return
    }

    new iKey[6], iAccess, iCallback, id2

    menu_item_getinfo(menu, item, iAccess, iKey, charsmax(iKey), _, _, iCallback)

    id2 = str_to_num(iKey)

    if(!is_available_to_party(id2))
        return

    show_party_invite_menu(id2, id)

    menu_destroy(menu)
}

public party_invite_menu(id, menu, item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        remove_task_acept(id)
        return
    }

    new iKey[6], iAccess, iCallback, id_master

    menu_item_getinfo(menu, item, iAccess, iKey, charsmax(iKey), _, _, iCallback)

    id_master = str_to_num(iKey)

    switch(item) {
        case 0: {

            if(!g_PartyData[id_master][In_Party]) {
                create_party(id_master, id)
                set_task_party_hud(id_master)
                set_task_party_hud(id)
            }
            else {
                if(g_PartyData[id_master][Amount_In_Party] == get_pcvar_num(cvar_max_players)) {

                    client_print(id, print_chat, "%s Ya se alcanzo el numero maximo de integrantes en la party", TAG)
                    client_print(id_master, print_chat, "%s Ya alcanzaste el numero maximo de integrantes en la party", TAG)

                    remove_task_acept(id)

                    menu_destroy(menu)
                    return
                }

                add_party_user(id_master, id)
                set_task_party_hud(id)
            }

            client_print(id_master, print_chat, "%s %s fue agregado al Party", TAG, g_PartyData[id][UserName])
        }
        case 1: client_print(id_master, print_chat, "%s %s cancelo la invitacion de Party", TAG, g_PartyData[id][UserName])
    }

    remove_task_acept(id)

    menu_destroy(menu)
}

public party_kick_menu(id, menu, item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return
    }

    new iKey[6], iAccess, iCallback, id2

    menu_item_getinfo(menu, item, iAccess, iKey, charsmax(iKey), _, _, iCallback)

    id2 = str_to_num(iKey)

    if(is_user_connected(id2))
        g_PartyData[id][Amount_In_Party] == 2 ? destoy_party(id) : remove_party_user(id2)

    menu_destroy(menu)
}

public party_info_menu(id, menu,item) {

    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return
    }

    switch(item) {
        case 0: {
            if(g_PartyData[id][Amount_In_Party] < get_pcvar_num(cvar_max_players))
                show_party_add_menu(id)
            else
                client_print(id, print_chat, "%s Ya alcanzaste el numero maximo de integrantes en la party", TAG)
        }
        case 1: show_party_kick_menu(id)
        case 2: destoy_party(id)
        case 3: remove_party_user(id)
    }

    menu_destroy(menu)
}

public PartyHud(taskid) {

    static id
    id = ID_HUD

    if(!is_user_connected(id)) {
        remove_task(taskid)
        return
    }

    static CountParty, PartyMsg[256], Players[32], id2

    CountParty = 0
    PartyMsg[0] = 0

    get_party_index(id, Players)
    for(new i; i < g_PartyData[id][Amount_In_Party]; i++) {

        id2 = Players[i]

        if(CountParty)
            add(PartyMsg, charsmax(PartyMsg), "^n")

        format(PartyMsg, charsmax(PartyMsg), "%s%s", strlen(PartyMsg) ? PartyMsg : "^t^t^tMiembros del Party^n", g_PartyData[id2][UserName])
        CountParty++
    }

    set_hudmessage(255, 255, 255, 0.75, 0.34, 0, 6.0, 1.0);
    show_hudmessage(id, PartyMsg)
}

public Time_Acept(UserTaskArgs[], taskid) {

    taskid -= TASK_ACEPT;

    if(!g_PartyData[taskid][In_Party]) {

        client_print(UserTaskArgs[1], print_chat, "%s %s cancelo la invitacion de party", TAG, g_PartyData[taskid][UserName])
        menu_destroy(UserTaskArgs[0])
        show_menu(taskid, 0, "^n", 1)
    }
}

stock create_party(master, guest) {

    set_party_member(master, master)
    set_party_member(master, guest)
    set_party_member(guest, master)
    set_party_member(guest, guest)

    set_party_vars(master, Start_Amount)
    set_party_vars(guest, ++g_PartyData[master][Amount_In_Party])
}

stock add_party_user(master, guest) {

    new Players[32], member, amount = g_PartyData[master][Amount_In_Party]

    get_party_index(master, Players)

    for(new i; i < amount; i++) {

        member = Players[i]

        set_party_member(guest, member)
        set_party_member(member, guest)
        g_PartyData[member][Amount_In_Party]++

    }

    set_party_member(guest, guest)
    set_party_vars(guest, amount+1)
}

stock set_party_member(id, id2)
    ArrayPushCell(Party_Ids[id], id2)

stock set_party_vars(id, amount) {

    g_PartyData[id][In_Party] = true
    g_PartyData[id][Position] = amount-1
    g_PartyData[id][Amount_In_Party] = amount

}

stock destoy_party(id) {

    new Players[32], id2, Amount = g_PartyData[id][Amount_In_Party]
    get_party_index(id, Players)

    for(new i; i < Amount; i++) {
        id2 = Players[i]
        clear_party_user(id2)
        client_print(id2, print_chat, "%s La party fue destruida", TAG)

    }
}

stock remove_party_user(user) {

    new Players[32], id, Amount = g_PartyData[user][Amount_In_Party]

    get_party_index(user, Players)

    clear_party_user(user)

    for(new i; i < Amount; i++) {

        id = Players[i]

        if(id != user) {

            ArrayClear(Party_Ids[id])

            for(new z; z < Amount; z++)
                if(Players[z] != user)
                    set_party_member(id, Players[z])

            g_PartyData[id][Position] = i
            g_PartyData[id][Amount_In_Party] = Amount-1
            client_print(id, print_chat, "%s %s salio del party", TAG, g_PartyData[user][UserName])
        }
    }
}

stock clear_party_user(id) {

    ArrayClear(Party_Ids[id])
    g_PartyData[id][In_Party] = false
    g_PartyData[id][Position] = NONE
    g_PartyData[id][Amount_In_Party] = NONE
    remove_task_party_hud(id)

}

stock set_task_party_hud(id)
    set_task(1.0, "PartyHud", id+TASK_HUD, _, _, "b")

stock remove_task_party_hud(id)
    remove_task(id+TASK_HUD)

stock remove_task_acept(id)
    if(task_exists(id+TASK_ACEPT))
        remove_task(id+TASK_ACEPT)


stock set_player_party_name(id) {

    if(g_PartyData[id][UserName][0])
        return 0

    get_user_name(id, g_PartyData[id][UserName], charsmax(g_PartyData[][UserName]))

    return 1
}

stock is_available_to_party(id) {

    if(!is_user_connected(id) || g_PartyData[id][In_Party] || g_PartyData[id][Block_Party])
        return false

    return true
}

stock get_party_index(id, players[]) {

    for(new i; i < g_PartyData[id][Amount_In_Party]; i++)
        players[i] = ArrayGetCell(Party_Ids[id], i)

    return players[0] ? 1 : 0
}

public check_master(id)
    return g_PartyData[id][Position] ? ITEM_DISABLED : ITEM_ENABLED

public check_user(id)
    return g_PartyData[id][Position] ? ITEM_ENABLED : ITEM_DISABLED

public cmdSayTeam(id) {

    static Text[192]
    read_args(Text, charsmax(Text))
    remove_quotes(Text)

    replace_all(Text, charsmax(Text), "%", "")

    if(!ValidMessage(Text) || !g_PartyData[id][In_Party]) {

        client_print(id, print_chat,"%s Tu Mensaje es invalido o no te encuentras en un Party", TAG)
        return PLUGIN_HANDLED;
    }

    static Message[192], Players[32], id2, Amount
    Amount = g_PartyData[id][Amount_In_Party]

    get_party_index(id, Players)

    formatex(Message, charsmax(Message), "^x04%s ^x03%s^x01 : %s", TAG, g_PartyData[id][UserName], Text)

    for(new i; i < Amount; i++) {

        id2 = Players[i]

        message_begin(MSG_ONE_UNRELIABLE, g_MsgSayText, _, id2)
        write_byte(id)
        write_string(Message)
        message_end()
    }

    return PLUGIN_HANDLED;
}

ValidMessage(text[]) {
    static len, i
    len = strlen(text)

    if(!len)
        return false

    for(i = 0; i < len; i++) {
        if( text[i] != ' ' ) {
            return true
        }
    }

    return false
}

//public native_ze_open_party_menu(id) //Quitar comentario si es para ZE
public native_ze_open_party_menu(id)
{
    if (!is_user_connected(id))
    {
        log_error(AMX_ERR_NATIVE, "[ZP AG] Invalid Player (%d)", id)
        return false
    }

    show_party_menu(id)
    return true
}
