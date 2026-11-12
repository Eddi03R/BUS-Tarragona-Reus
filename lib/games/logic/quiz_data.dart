/// Domande del quiz su Tarragona, Santa Tecla, Spagna e Catalogna.
/// Le risposte sono nomi propri, date o numeri uguali in tutte le lingue:
/// cambia solo il testo della domanda.
enum QuizCat { tarragona, santaTecla, spain, catalonia }

class QuizQuestion {
  final QuizCat cat;
  final Map<String, String> text; // it, en, es, ca, de
  final List<String> options;
  final int answer; // indice in [options]
  const QuizQuestion(this.cat, this.text, this.options, this.answer);

  String textFor(String lang) => text[lang] ?? text['en']!;
}

const _t = QuizCat.tarragona;
const _s = QuizCat.santaTecla;
const _e = QuizCat.spain;
const _c = QuizCat.catalonia;

const List<QuizQuestion> quizQuestions = [
  // ------------------------------------------------------------- Tarragona
  QuizQuestion(_t, {
    'it': 'Come si chiamava Tarragona in epoca romana?',
    'en': 'What was Tarragona called in Roman times?',
    'es': '¿Cómo se llamaba Tarragona en época romana?',
    'ca': 'Com es deia Tarragona en època romana?',
    'de': 'Wie hieß Tarragona in römischer Zeit?',
  }, ['Tarraco', 'Barcino', 'Emporiae', 'Ilerda'], 0),
  QuizQuestion(_t, {
    'it': 'In che anno i monumenti romani di Tarragona sono diventati Patrimonio UNESCO?',
    'en': 'In which year did the Roman monuments of Tarragona become a UNESCO World Heritage Site?',
    'es': '¿En qué año los monumentos romanos de Tarragona fueron declarados Patrimonio de la Humanidad?',
    'ca': 'En quin any els monuments romans de Tarragona van ser declarats Patrimoni de la Humanitat?',
    'de': 'In welchem Jahr wurden die römischen Denkmäler von Tarragona UNESCO-Welterbe?',
  }, ['1985', '1993', '2000', '2010'], 2),
  QuizQuestion(_t, {
    'it': 'Come si chiama il famoso belvedere sul mare in cima alla Rambla Nova?',
    'en': 'What is the famous sea viewpoint at the end of Rambla Nova called?',
    'es': '¿Cómo se llama el famoso mirador sobre el mar al final de la Rambla Nova?',
    'ca': 'Com es diu el famós mirador sobre el mar al final de la Rambla Nova?',
    'de': 'Wie heißt der berühmte Aussichtspunkt am Meer am Ende der Rambla Nova?',
  }, ['Balcó del Mediterrani', 'Mirador de l\'Ebre', 'Pas de Roma', 'Platja del Miracle'], 0),
  QuizQuestion(_t, {
    'it': 'Quale quartiere di Tarragona è il tradizionale quartiere dei pescatori?',
    'en': 'Which neighbourhood of Tarragona is the traditional fishermen\'s quarter?',
    'es': '¿Qué barrio de Tarragona es el tradicional barrio de pescadores?',
    'ca': 'Quin barri de Tarragona és el tradicional barri de pescadors?',
    'de': 'Welches Viertel von Tarragona ist das traditionelle Fischerviertel?',
  }, ['El Serrallo', 'Torreforta', 'Bonavista', 'Campclar'], 0),
  QuizQuestion(_t, {
    'it': 'Quale edificio romano di Tarragona si affaccia direttamente sul mare?',
    'en': 'Which Roman building in Tarragona looks directly onto the sea?',
    'es': '¿Qué edificio romano de Tarragona da directamente al mar?',
    'ca': 'Quin edifici romà de Tarragona dóna directament al mar?',
    'de': 'Welches römische Bauwerk in Tarragona liegt direkt am Meer?',
  }, ['Amfiteatre', 'Fòrum', 'Teatre', 'Mausoleu'], 0),
  QuizQuestion(_t, {
    'it': 'Come è conosciuto l\'acquedotto romano di les Ferreres?',
    'en': 'What is the Roman aqueduct of les Ferreres commonly known as?',
    'es': '¿Cómo se conoce el acueducto romano de les Ferreres?',
    'ca': 'Com es coneix l\'aqüeducte romà de les Ferreres?',
    'de': 'Wie ist das römische Aquädukt von les Ferreres bekannt?',
  }, ['Pont del Diable', 'Pont de Pedra', 'Pont Vell', 'Pont de la Reina'], 0),
  QuizQuestion(_t, {
    'it': 'In quale città del Camp de Tarragona si produce il famoso vermut?',
    'en': 'In which city of the Camp de Tarragona is the famous vermouth produced?',
    'es': '¿En qué ciudad del Camp de Tarragona se elabora el famoso vermut?',
    'ca': 'En quina ciutat del Camp de Tarragona s\'elabora el famós vermut?',
    'de': 'In welcher Stadt des Camp de Tarragona wird der berühmte Wermut hergestellt?',
  }, ['Reus', 'Valls', 'Salou', 'Cambrils'], 0),
  QuizQuestion(_t, {
    'it': 'Quale stazione balneare vicina a Tarragona è famosa per il suo lungomare e per PortAventura?',
    'en': 'Which seaside resort near Tarragona is famous for its promenade and for PortAventura?',
    'es': '¿Qué localidad costera cercana a Tarragona es famosa por su paseo marítimo y por PortAventura?',
    'ca': 'Quina població costanera propera a Tarragona és famosa pel seu passeig marítim i per PortAventura?',
    'de': 'Welcher Badeort bei Tarragona ist für seine Strandpromenade und PortAventura berühmt?',
  }, ['Salou', 'Altafulla', 'Calafell', 'L\'Ametlla de Mar'], 0),

  // ----------------------------------------------------------- Santa Tecla
  QuizQuestion(_s, {
    'it': 'Di quale città è patrona Santa Tecla?',
    'en': 'Of which city is Santa Tecla the patron saint?',
    'es': '¿De qué ciudad es patrona Santa Tecla?',
    'ca': 'De quina ciutat és patrona Santa Tecla?',
    'de': 'Welcher Stadt ist die heilige Thekla Schutzpatronin?',
  }, ['Tarragona', 'Reus', 'Barcelona', 'Girona'], 0),
  QuizQuestion(_s, {
    'it': 'Qual è il giorno della festa di Santa Tecla?',
    'en': 'On which day is the feast of Santa Tecla?',
    'es': '¿Qué día es la fiesta de Santa Tecla?',
    'ca': 'Quin dia és la festa de Santa Tecla?',
    'de': 'An welchem Tag wird das Fest der Santa Tecla gefeiert?',
  }, ['23/09', '23/04', '24/06', '11/09'], 0),
  QuizQuestion(_s, {
    'it': 'Quale animale festivo del Seguici Popular di Tarragona è un\'aquila?',
    'en': 'Which festive beast of the Tarragona Seguici Popular is an eagle?',
    'es': '¿Qué animal festivo del Seguici Popular de Tarragona es un águila?',
    'ca': 'Quin animal festiu del Seguici Popular de Tarragona és una àguila?',
    'de': 'Welches Festtier des Seguici Popular von Tarragona ist ein Adler?',
  }, ['Àliga', 'Drac', 'Mulassa', 'Bou'], 0),
  QuizQuestion(_s, {
    'it': 'Come si chiama la base di una torre umana (castell)?',
    'en': 'What is the base of a human tower (castell) called?',
    'es': '¿Cómo se llama la base de una torre humana (castell)?',
    'ca': 'Com es diu la base d\'un castell?',
    'de': 'Wie heißt die Basis eines Menschenturms (Castell)?',
  }, ['Pinya', 'Tronc', 'Folre', 'Manilles'], 0),
  QuizQuestion(_s, {
    'it': 'Come si chiama il bambino che incorona la torre umana?',
    'en': 'What is the child who crowns the human tower called?',
    'es': '¿Cómo se llama el niño que corona la torre humana?',
    'ca': 'Com es diu l\'infant que corona el castell?',
    'de': 'Wie heißt das Kind, das den Menschenturm krönt?',
  }, ['Enxaneta', 'Acotxador', 'Dosos', 'Canalla'], 0),
  QuizQuestion(_s, {
    'it': 'In che anno i Castellers sono stati dichiarati Patrimonio immateriale dell\'UNESCO?',
    'en': 'In which year were the Castellers declared UNESCO Intangible Cultural Heritage?',
    'es': '¿En qué año los Castellers fueron declarados Patrimonio Inmaterial por la UNESCO?',
    'ca': 'En quin any els Castellers van ser declarats Patrimoni Immaterial per la UNESCO?',
    'de': 'In welchem Jahr wurden die Castellers zum immateriellen UNESCO-Kulturerbe erklärt?',
  }, ['2000', '2005', '2010', '2015'], 2),
  QuizQuestion(_s, {
    'it': 'Ogni quanti anni si tiene il Concurs de Castells di Tarragona?',
    'en': 'How often is the Tarragona Concurs de Castells held?',
    'es': '¿Cada cuántos años se celebra el Concurs de Castells de Tarragona?',
    'ca': 'Cada quants anys se celebra el Concurs de Castells de Tarragona?',
    'de': 'Wie oft findet der Concurs de Castells in Tarragona statt?',
  }, ['1', '2', '3', '5'], 1),

  // ---------------------------------------------------------------- Spagna
  QuizQuestion(_e, {
    'it': 'Qual è la capitale della Spagna?',
    'en': 'What is the capital of Spain?',
    'es': '¿Cuál es la capital de España?',
    'ca': 'Quina és la capital d\'Espanya?',
    'de': 'Was ist die Hauptstadt von Spanien?',
  }, ['Madrid', 'Barcelona', 'Sevilla', 'Valencia'], 0),
  QuizQuestion(_e, {
    'it': 'Qual è il fiume più lungo della penisola iberica?',
    'en': 'Which is the longest river of the Iberian Peninsula?',
    'es': '¿Cuál es el río más largo de la península ibérica?',
    'ca': 'Quin és el riu més llarg de la península Ibèrica?',
    'de': 'Welcher ist der längste Fluss der Iberischen Halbinsel?',
  }, ['Tajo', 'Ebro', 'Duero', 'Guadalquivir'], 0),
  QuizQuestion(_e, {
    'it': 'Qual è la montagna più alta della Spagna?',
    'en': 'What is the highest mountain in Spain?',
    'es': '¿Cuál es la montaña más alta de España?',
    'ca': 'Quina és la muntanya més alta d\'Espanya?',
    'de': 'Was ist der höchste Berg Spaniens?',
  }, ['Teide', 'Mulhacén', 'Aneto', 'Torre Cerredo'], 0),
  QuizQuestion(_e, {
    'it': 'Chi ha scritto «Don Chisciotte della Mancia»?',
    'en': 'Who wrote "Don Quixote"?',
    'es': '¿Quién escribió «Don Quijote de la Mancha»?',
    'ca': 'Qui va escriure «Don Quixot de la Manxa»?',
    'de': 'Wer schrieb «Don Quijote»?',
  }, ['Cervantes', 'Lorca', 'Machado', 'Unamuno'], 0),
  QuizQuestion(_e, {
    'it': 'Quante comunità autonome ha la Spagna?',
    'en': 'How many autonomous communities does Spain have?',
    'es': '¿Cuántas comunidades autónomas tiene España?',
    'ca': 'Quantes comunitats autònomes té Espanya?',
    'de': 'Wie viele Autonome Gemeinschaften hat Spanien?',
  }, ['15', '17', '19', '21'], 1),
  QuizQuestion(_e, {
    'it': 'Da quale regione proviene la paella?',
    'en': 'Which region does paella come from?',
    'es': '¿De qué región procede la paella?',
    'ca': 'De quina regió procedeix la paella?',
    'de': 'Aus welcher Region stammt die Paella?',
  }, ['Valencia', 'Galicia', 'Andalucía', 'Navarra'], 0),
  QuizQuestion(_e, {
    'it': 'Dove si svolge la «Tomatina», la battaglia dei pomodori?',
    'en': 'Where is the "Tomatina" tomato fight held?',
    'es': '¿Dónde se celebra la «Tomatina», la batalla de tomates?',
    'ca': 'On se celebra la «Tomatina», la batalla de tomàquets?',
    'de': 'Wo findet die «Tomatina», die Tomatenschlacht, statt?',
  }, ['Buñol', 'Pamplona', 'Sitges', 'Xàtiva'], 0),
  QuizQuestion(_e, {
    'it': 'Chi ha dipinto «Guernica»?',
    'en': 'Who painted "Guernica"?',
    'es': '¿Quién pintó el «Guernica»?',
    'ca': 'Qui va pintar el «Guernica»?',
    'de': 'Wer malte «Guernica»?',
  }, ['Picasso', 'Dalí', 'Miró', 'Goya'], 0),

  // -------------------------------------------------------------- Catalogna
  QuizQuestion(_c, {
    'it': 'Quante province ha la Catalogna?',
    'en': 'How many provinces does Catalonia have?',
    'es': '¿Cuántas provincias tiene Cataluña?',
    'ca': 'Quantes províncies té Catalunya?',
    'de': 'Wie viele Provinzen hat Katalonien?',
  }, ['3', '4', '5', '6'], 1),
  QuizQuestion(_c, {
    'it': 'Chi ha progettato la Sagrada Família?',
    'en': 'Who designed the Sagrada Família?',
    'es': '¿Quién diseñó la Sagrada Família?',
    'ca': 'Qui va dissenyar la Sagrada Família?',
    'de': 'Wer entwarf die Sagrada Família?',
  }, ['Gaudí', 'Domènech i Montaner', 'Puig i Cadafalch', 'Dalí'], 0),
  QuizQuestion(_c, {
    'it': 'Quale monastero cistercense, Patrimonio UNESCO, si trova nella provincia di Tarragona?',
    'en': 'Which Cistercian monastery, a UNESCO World Heritage Site, is in the province of Tarragona?',
    'es': '¿Qué monasterio cisterciense, Patrimonio de la Humanidad, está en la provincia de Tarragona?',
    'ca': 'Quin monestir cistercenc, Patrimoni de la Humanitat, és a la província de Tarragona?',
    'de': 'Welches Zisterzienserkloster, UNESCO-Welterbe, liegt in der Provinz Tarragona?',
  }, ['Poblet', 'Montserrat', 'Ripoll', 'Sant Cugat'], 0),
  QuizQuestion(_c, {
    'it': 'Quale fiume forma il delta in provincia di Tarragona?',
    'en': 'Which river forms the delta in the province of Tarragona?',
    'es': '¿Qué río forma el delta en la provincia de Tarragona?',
    'ca': 'Quin riu forma el delta a la província de Tarragona?',
    'de': 'Welcher Fluss bildet das Delta in der Provinz Tarragona?',
  }, ['Ebre', 'Llobregat', 'Ter', 'Segre'], 0),
  QuizQuestion(_c, {
    'it': 'Qual è la vetta più alta della Catalogna?',
    'en': 'What is the highest peak in Catalonia?',
    'es': '¿Cuál es el pico más alto de Cataluña?',
    'ca': 'Quin és el cim més alt de Catalunya?',
    'de': 'Was ist der höchste Gipfel Kataloniens?',
  }, ['Pica d\'Estats', 'Aneto', 'Montseny', 'Puigmal'], 0),
  QuizQuestion(_c, {
    'it': 'Quando si celebra Sant Jordi, la festa dei libri e delle rose?',
    'en': 'When is Sant Jordi, the day of books and roses, celebrated?',
    'es': '¿Cuándo se celebra Sant Jordi, el día de los libros y las rosas?',
    'ca': 'Quan se celebra Sant Jordi, el dia dels llibres i les roses?',
    'de': 'Wann wird Sant Jordi, der Tag der Bücher und Rosen, gefeiert?',
  }, ['23/04', '23/09', '11/09', '01/05'], 0),
  QuizQuestion(_c, {
    'it': 'In quale città è nato Salvador Dalí?',
    'en': 'In which town was Salvador Dalí born?',
    'es': '¿En qué ciudad nació Salvador Dalí?',
    'ca': 'En quina ciutat va néixer Salvador Dalí?',
    'de': 'In welcher Stadt wurde Salvador Dalí geboren?',
  }, ['Figueres', 'Cadaqués', 'Girona', 'Roses'], 0),
  QuizQuestion(_c, {
    'it': 'In quale valle dei Pirenei catalani la lingua ufficiale è anche l\'occitano (aranese)?',
    'en': 'In which Catalan Pyrenees valley is Occitan (Aranese) also an official language?',
    'es': '¿En qué valle del Pirineo catalán el occitano (aranés) es también lengua oficial?',
    'ca': 'En quina vall del Pirineu català l\'occità (aranès) també és llengua oficial?',
    'de': 'In welchem katalanischen Pyrenäental ist Okzitanisch (Aranesisch) ebenfalls Amtssprache?',
  }, ['Val d\'Aran', 'Cerdanya', 'Ripollès', 'Garrotxa'], 0),
  QuizQuestion(_c, {
    'it': 'Con quale ortaggio si fa la «calçotada», tipica di Valls?',
    'en': 'Which vegetable is eaten at a "calçotada", typical of Valls?',
    'es': '¿Qué hortaliza se come en una «calçotada», típica de Valls?',
    'ca': 'Quina hortalissa es menja en una calçotada, típica de Valls?',
    'de': 'Welches Gemüse isst man bei einer «Calçotada», typisch für Valls?',
  }, ['Calçots', 'Carxofes', 'Albergínies', 'Espàrrecs'], 0),
  QuizQuestion(_c, {
    'it': 'In che anno si sono svolte le Olimpiadi di Barcellona?',
    'en': 'In which year were the Barcelona Olympic Games held?',
    'es': '¿En qué año se celebraron los Juegos Olímpicos de Barcelona?',
    'ca': 'En quin any es van celebrar els Jocs Olímpics de Barcelona?',
    'de': 'In welchem Jahr fanden die Olympischen Spiele in Barcelona statt?',
  }, ['1980', '1988', '1992', '2000'], 2),
  QuizQuestion(_c, {
    'it': 'Quale monastero benedettino sorge su una montagna dalla forma seghettata vicino a Barcellona?',
    'en': 'Which Benedictine monastery stands on a serrated mountain near Barcelona?',
    'es': '¿Qué monasterio benedictino se alza sobre una montaña aserrada cerca de Barcelona?',
    'ca': 'Quin monestir benedictí s\'alça sobre una muntanya serrada prop de Barcelona?',
    'de': 'Welches Benediktinerkloster steht auf einem gezackten Berg bei Barcelona?',
  }, ['Montserrat', 'Poblet', 'Santes Creus', 'Ripoll'], 0),
];
