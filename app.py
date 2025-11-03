import os
import sys
from flask import Flask, jsonify, render_template_string, request

app = Flask(__name__)

mo
items = [

    {"id": 2, "name": "Containe
    {"id": 3, "name": "GitHu
]
next_id = 4

# Try to import database dependes
try:
    import pyodbc
    DB_AVAILABLE = True
except ImportError:
    False
    print("Database driver not availabl")

def get_db_connection():
    """Get database connection o""
    VAILABLE:
        return None
    
    try:
        # Try to connse
        server = os.environ.get('SQL_SERVER')
        database = os.environ.get('SQL_DATABASE')
        username = os.environ.get('SQL_ADMIN')
        password = os.environ.get('SORD')
        
        if all([server, database, username, pass
    ;"
            return pyodbc.connect(connection_strng)
    except Ex as e:

    
    return None

HTML_TEMPLATE = '''
<!DO
<html>
<head>
    <title>Azure CRUD App /title>
    <link href="https://cdn.jsdelivr.net/npm/boo">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-aw">

<body>
<div class="container mt-4">
    <div="row">
        <div class="col-12">
            <div class="card b">
        
                    <h1><i class="fas fa-rocket"ized!</h1>
                    <p cla
                </div>
            </div>
        </div>
    </div>
    
    <div class="row mt-4">
        <div class="col-md-4">
            <">
            ">
        
                </div
                <div cd-body">
                    p>
                    <p><strong>Container:</strong>p>
                    <p><st/p>
                    <p><strong>Database:</strong> <s
                    <p><strong>Items:</strong> {{ items|length }}<p>
>
            </div>
        </di
        
        <div class="col-md-8">
            <div class="card b>
                <div class="card-header bg-info text-white">
                    <h5><i class=
                </div>
                <div
        >
                        <div class="row">
                          6">
                                <div class="mb-3">

                                    <inpured>
                
        /div>
                            <div c
                              b-3">
                                    <label class="form-label">Description</label>
                                 n">
                      
                    >
        >
                       ">
                          de }}
                        </butto
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <div
        <div class="col-12">
            <div class="ca
                <div class="card-header">
>
                </div>
                <d">
        
                    <div class="t">
                        <table -hover">
                            <thead class="table-d">
        r>
                    
                                    <th><i class="fas fa-tag">
        </th>
                                  
                              >
                       d>
                            <tbody>
                               
         tr>
                     
        
                              d>
                                    <td>
                                ">
                      lete
                    utton>
        /td>
                        
                          }
                            
                        </table>
                    </div>
                    {% else %}
               
                        <iems above!
                    </div>
}
                </div>
            </div>
        /div>
    </div>
    
    <div class="row mt-4">
        <div class="col-md-6">
            <div classdary">
                <div
        ints</h5>
                </div>
                <div class="card-body">
        ">
                        /li>
                        <lh</a></li>
                        <li>i>
                    </ul>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
ry">
                <div class="card-header">
                    <h5><5>
        
                <div class="card-">
                    <p><strong>
                    <p><strong>Platform:</strong>>
        0</p>
                    ></p>
                </div>
          </div>
        </div>
    </div>
</div>

<script>
document.e) {
    e.prfault();
    const name = document.getEleue;
    const description = do
    
    try {
        ', {
            method: '',
        
            body: JSON.stringi)
        });
        
        if (response.ok) {
            locationad();
        se {
            const error ;
            alert('Error: 
        }
    } catch (error) {
        alert('Network error: ' + error.message);
    }
});

async function deleteItem(id) {

        try {
            const respons});
        ok) {
                location.reload();
            } else {
                const error = await response.json();
        
            }
        } catch (error) {
            alert('Netwo;
        }
    }
}
</script>
</body>
</html>
'''

@app.route('/')
dex():
    """Main page show"
    conn = get_db_c()
    db_m"
    
    if conn:
        # Use database
        try:
            cursor = cursor()
            cursor.e
            db_items = cursor.fetchall()
            items_list = [
            cursor.close()

        except Excepion as e:
            print
            items_list = items
            db_mo
    else:
        # Use in-memory
        items_list = items
    
    return render_teTE, 
                                items=item 
                                db_mode=db_mode,
                                python_v
      atform)

@app.route('/api/items', m'GET'])
def get_items():
    """Get all items as JSON"""onn = get_db_connection() f conn:     try:      lse), debug=Fa=portport, 0.0'n(host='0.0.    app.ru000))
'PORT', 8get(os.environ.ort = int(  pon
  pplicati aun the 
    # R
   ")ed: {e}ion failializatase initDatabf" print(           tion as e:
Excep     except   
 y")fullzed successalibase initiDataint(" pr         .close()
    conn  ()
        rsor.close  cu    t()
      n.commi con        )
   ""         "     )
           TDATE()
   FAULT GEE2 DEETIM DATpdated_at     u             DATE(),
  FAULT GETME2 DEATETI Deated_at cr                 X),
  RCHAR(MAcription NVA   des            NULL,
     T NOCHAR(255) AR  name NV         
         EY, PRIMARY KITY(1,1)NT IDENT    id I        (
        BLE Items    CREATE TA       'U')
      e=ND xtypms' Aname='IteE WHERects ROM sysobj FELECT *ISTS (SIF NOT EX              """
  xecute(rsor.e      cu
      ursor().c conn =or       cursy:
     tr   
      conn:on()
    ifnnectidb_coconn = get_
    ilablee if avaize databas # Initialin__':
   ma_ == '____name_  })

if : 8000
  "port"        on'),
', 'productiSK_ENVget('FLAn.nviroment": os.e   "environ    ABLE,
  DB_AVAIL":vailablease_aatab"d    ,
    latforms.patform": sy       "pln,
 ys.versioersion": sython_v     "p,
   er": True   "contain     "1.0.0",
ion":    "verspp",
      Are CRUDAzution": " "applica      ({
 turn jsonify"
    re info""onapplicatitainer and """Connfo():
    
def ite('/info')pp.rou

@a     }) True
   ":ainer     "cont       
(items),ount": len"items_c           ry",
 n-memo"i ":"database            ",
healthytus": "    "sta({
        jsonifyreturn    e:
        els
  200      }),rue
      ": Tntainer        "co",
        -memory "in":allback   "f             (e),
rror": str         "e       rror",
ction_e": "conne "database        ",
       ddeegra": "dus     "stat         {
  onify(   return js         
eption as e:Excxcept      e        })
     e
   Trutainer":on       "c    ,
     : countms_count"te         "i
       tabase",re SQL Da"Azu": baseata   "d            ",
 hy "healt"status":            ({
    n jsonify retur          )
 se(onn.clo           c()
 rsor.close          cu  one()[0]
cursor.fetchount =         c")
     ItemsUNT(*) FROMECT CO"SELor.execute(curs        sor()
    ur = conn.cursor    c:
             tryn:
    if con)
    
   onnection(_c_dbnn = get""
    codpoint"th check en"Heal"":
    ef health()
dhealth')route('/)

@app.cessfully"}ed suc delete": "Item({"messagfyeturn jsoni]
        ritem_id= id"] !item["items if em in em for it[itms = 
        itel items      globastorage
  n-memory      # I:
       else0
r(e)}), 50rror": stsonify({"e return j          e:
 on as pt Excepti      exce
  sfully"})ccessuleted tem de "I":"message jsonify({      return()
       conn.close         ()
  ursor.close        cmmit()
    nn.co   co
         nd"}), 404not fou"Item ": or{"errurn jsonify(  ret             
 = 0:unt =or.rowcof curs   i        )
 m_id,)", (iteHERE id = ?ROM Items WETE F"DELte(r.execurso        cu    or()
conn.curscursor =             ry:

        t   if conn: 
 )
   ction(b_conne get_d conn =""
   item"ete an ""Del
    "m_id):ete_item(ite])
def delELETE'hods=['D, metm_id>'<int:items//api/iteoute('@app.r01

m), 2nify(new_iteso    return j= 1
    xt_id +     ne)
   w_itemnd(ne items.appe
              }tion
 ": descripdescription         "   : name,
  "name"     ,
      next_id    "id":      em = {
    new_itrage
      sto# In-memory :
        lse e}), 500
   e) str(or":rrjsonify({"e  return        n as e:
   xceptiot E       excep
 201sfully"}), eated succes: "Item cre"essag({"mnify return jso     )
      .close(nn    co        ()
se.clo   cursor
         .commit()      connn))
      descriptio, me ?)", (naVALUES (?,ription) , descms (nameRT INTO Iteecute("INSEexcursor.          or()
  rs conn.cucursor =           try:
 n:
        
    if conon()
    nectiet_db_con gconn =    
    tion', '')
('descrip= data.getscription 
    de')'namea.get(e = dat   
    nam"}), 400
 quired is re": "Nameorfy({"errurn jsoni      ret):
  name'ta.get('ot da ndata orif not on()
    get_jsquest.a = re   
    datd
 bal next_i   glo"
 tem""ate a new iCre   """em():
 itreate_])
def cs=['POST', methodpi/items''/aoute(

@app.ritems)n jsonify( returse:
        el500
   , tr(e)})": srror({"en jsonify      returs e:
      eption apt Excce
        exems_list)nify(iturn jso ret     
      e()n.clos         con)
   or.close(       curs   })
               None
   3] else () if row[.isoformatw[3]ro": _atedat      "cre             ,
 ": row[2]ionescript       "d   
          ": row[1],  "name            
       row[0],"id":             
        ist.append({_ltems  i     
         items:n db_w i  for ro          list = []
   items_)
         ll(ha.fetcems = cursor  db_it         
 ")DESCd_at R BY createItems ORDEat FROM ed_reation, c descriptname,, "SELECT id.execute(sor        curr()
     conn.curso = cursor
     
   
    i
   
    c