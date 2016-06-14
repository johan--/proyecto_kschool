


Welcome to proyecto master data science
==================================


Proyecto parte del master de data science. Tratando de aplicar los aprendido, espero que os guste y muestre la evolución de la nada a algo!.

----------

Pregunta
-------------
A raíz de [varios casos de insultos machistas a políticas] me surgen varías preguntas:

 - ¿Qué es lo que se dice a los políticos?
 - ¿Se insulta más a las ** políticas Mujeres**?

Veamos los pasos que he dado `[TOC]`:

[TOC]


Datos
-------------
Para analizar que se dice cuándo se menciona en twitter a las personas que se presentan a las elecciones del 26 de junio.

Se ha elegido de las personas que se presentan a las elecciones por cada partido, las 3 mujeres y los 3 hombres que más seguidores según el ranking que realiza [t-cracia](http://www.t-cracia.info/):

> Listado de los perfiles elegidos [ \[0.nombres_perfiles\]](https://github.com/ledaduelo/proyecto_kschool/blob/master/0.nombres_perfiles).


### extracción desde twitter

Utilizando la librería tweepy ! primero [la autorización](https://github.com/ledaduelo/proyecto_kschool/blob/master/1.extraccion_conclaves.ipynb) para poder acceder

Y luego para extraer las [menciones a cada político](https://github.com/ledaduelo/proyecto_kschool/blob/master/1.stream_agarzon.ipynb)


```
lass MyListener(StreamListener):
    def on_data(self, data):
        try:
            with open('agarzon.json', 'a') as f:
                f.write(data)
                return True
        except BaseException as e:
            print("Error on_data: %s" % str(e))
        return True
 
    def on_error(self, status):
        print(status)
        return True
 
twitter_stream = Stream(auth, MyListener())
twitter_stream.filter(track=['@agarzon'])
```

Pero la api tiene [varios límites](https://dev.twitter.com/rest/public/rate-limiting): por tiempo y por volumen de consultas ...


### Brandwatch

Creo para cada grupo de partido y genero una [querie](https://www.brandwatch.com/queries/) 

Luego me bajo los datos por el [API](https://www.brandwatch.com/es/developers/) 

 1. Se genera el token
 2. Se construye la url para cada consulta
 3. Se obtienen los datos

```
def get_mentions_query_URL(start_date,end_date,project_id,query_id,access_token,fullText):
	query_def = "data/mentions" 
	end_date = "endDate=" + end_date + "T00:00:00.000Z"
	start_date = "startDate=" + start_date + "T00:00:00.000Z"
	request_URL = "https://newapi.brandwatch.com/projects/" + str(project_id) + "/" + query_def
	if fullText == True:
		request_URL = request_URL + "/fulltext"
	request_URL = request_URL + "?" + "queryId=" + str(query_id) + "&" + start_date + "&" + end_date + "&pageSize=5000" + "&access_token=" + access_token
	return request_URL

def get_mentions_data(request_URL):
	response = requests.get(request_URL)
	print (response.status_code)
	if response.status_code != 200:
		print ("Query: failure")
		print request_URL
		print response.text
	project_json = json.loads(response.text)
	return project_json
```

Luego se convierte en pandas !!! ![emoji panda](http://pix.iemoji.com/images/emoji/apple/ios-9/256/panda-face.png)

Está cada ejemplo en git,  [2.api_brandwach_querie.ipynb](https://github.com/ledaduelo/proyecto_kschool/blob/master/2.%20api_brandwach_ciudadanos_m.ipynb)

Pero necesitaba el texto, y no puede acceder a el, a 

### CSVKIT

Baje los excel a mano desde la plataforma, los convertí en csv y los uni :

Los pasamos a csv
```
install csvkit
cd ./Downloads

in2csv mentions0.xls > mentions0.csv
in2csv mentions000.xls > mentions000.csv
```
... 

Los unimos
```
csvstack mentions0.csv mentions000.csv> datos_total0.csv
csvstack mentions1.csv datos_total0.csv> datos_total.csv
```

```
csvcut -c 2,3,7,42,59,82,101 datos_total32.csv
csvcut -c datos_total32.csv.csv | csvlook | head
```

Análisis
-------------

### Analizar las palabras más utilizadas

Utilizando la librería nltk analizamos [las palabras más utilizadas](https://github.com/ledaduelo/proyecto_kschool/blob/master/text2_procesamiento.ipynb) 

```
from collections import Counter
c = Counter(r2)
c.most_common(n=500)
```

Las palabras están muy asociadas a las campañas y titulares de noticias.

Hago una lista de adjetivos (quitanto los RT) y clasifico en brandwatch las menciones. (Se puede ver en la plataforma en data). 

De las xxx menciones de lás cuáles menos de 3 mil menciones son insultos o piropos

Visualización
-------------
### Dashboard

En el dashboard de brandwatch se puede ver la comparativa con las menciones sin insultos o piropos
En nº totales se habla de las mujeres un **7% de las menciones**.

![Total menciones](https://lh3.googleusercontent.com/I1jq6qmJIIBuh1VlLaFlkT3E2emAfD5hBOsOByCLsrzyarQxjRZWC5iXcgVA9zWgg96xkac9=s150 "menciones.png")

En las menciones que se insulta las mujeres ocupan un **14% de las menciones**.
![enter image description here](https://lh3.googleusercontent.com/mES9xvIMbF2YKItxE4dkRgReCPTX5yAL9u1IDRP-tvE5trUoapRfEpS3enzvSHSzu2BZOB3S=s150 "menciones_insultosypiropos.png")

Y para analizar que se dice, quién o donde he utilizado Tableau

[Análisis](https://public.tableau.com/profile/leda.duelo#!/vizhome/prueba1_71/Story1) de cuánto se insulta y a quién :


Libro de tableau [para descargar] (https://github.com/ledaduelo/proyecto_kschool/blob/master/insultos_politicos.twbx)

### Modelo

Para analizar el éxito (Reach) de los insultos se ha analizado si las variables de a que político se insulta (querie_name, que indica si es hombre o mujer y que partido) o si tiene más éxito el tipo de insulto .

Análisis [lm](https://github.com/ledaduelo/proyecto_kschool/blob/master/4.modelos_insultosypiropos.R):


> Written with [StackEdit](https://stackedit.io/).

