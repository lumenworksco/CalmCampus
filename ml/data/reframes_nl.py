"""Dutch (Flemish student) reframing examples. (thought, pattern, [three alternative thoughts])"""

DATA = [
    ("Ik ben gebuisd voor wiskunde, ik ga nooit afstuderen.", "catastrophizing", [
        "Eén buis betekent niet dat ik nooit afstudeer; er is nog een herexamen.",
        "Veel studenten slagen pas in tweede zit voor een moeilijk vak.",
        "Ik kan bekijken wat misliep en mijn aanpak voor augustus aanpassen."]),
    ("Iedereen in de les vindt mij raar.", "mind_reading", [
        "Ik weet niet wat iedereen denkt; de meesten zijn met zichzelf bezig.",
        "Ik kom misschien anders over dan ik me voel.",
        "Ik kan met één medestudent een gesprek beginnen en zien hoe dat loopt."]),
    ("Ik zou veel meer moeten studeren dan ik doe.", "should_statements", [
        "Ik kan altijd meer doen, maar ik doe al meer dan ik mezelf toegeef.",
        "Rust hoort bij goed studeren.",
        "Ik kan een haalbaar plan maken in plaats van mezelf te verwijten."]),
    ("Ik ben gewoon dom.", "labeling", [
        "Ik vind dit vak moeilijk, maar dat maakt mij niet dom.",
        "Iedereen loopt soms vast als die iets nieuws leert.",
        "Ik kan uitzoeken welk deel ik niet snap en daar hulp bij vragen."]),
    ("Mijn kotgenoten zitten altijd samen zonder mij, ze willen mij er niet bij.", "mind_reading", [
        "Misschien beseffen ze niet dat ik er graag bij zou zijn.",
        "Dat ze samen zitten, betekent niet dat ze mij buitensluiten.",
        "Ik kan zelf eens voorstellen om samen te koken."]),
    ("Ik heb mijn blok volledig verprutst.", "all_or_nothing", [
        "Mijn blok liep niet zoals gepland, maar ik heb wel dingen geleerd.",
        "Ik kan de dagen die overblijven nog goed gebruiken.",
        "Ik kan me focussen op de belangrijkste hoofdstukken."]),
    ("Als ik dit examen niet haal, ben ik een mislukking.", "all_or_nothing", [
        "Een examen niet halen maakt mij geen mislukking.",
        "Mijn waarde hangt niet af van één resultaat.",
        "Er zijn altijd nog opties, zoals een herexamen."]),
    ("Ik heb een 12 maar dat stelt niks voor.", "discounting_positives", [
        "Een 12 is een geslaagd resultaat waar ik voor gewerkt heb.",
        "Ik mag trots zijn op wat ik bereikt heb.",
        "Ik kan blij zijn met dit punt en toch ambitie hebben voor later."]),
    ("Ik voel me een bedrieger, dus ik hoor hier niet thuis.", "emotional_reasoning", [
        "Me een bedrieger voelen is iets wat heel veel studenten ervaren.",
        "Ik ben hier binnengeraakt door mijn eigen werk.",
        "Mijn gevoel is echt, maar het is geen bewijs."]),
    ("Mijn prof antwoordt niet op mijn mail, hij vindt mijn vraag vast dom.", "mind_reading", [
        "Proffen krijgen enorm veel mails en antwoorden soms traag.",
        "Een trage reactie zegt niets over mijn vraag.",
        "Ik kan na een week een korte herinnering sturen."]),
    ("Ik maak altijd dezelfde fouten.", "overgeneralizing", [
        "Sommige fouten komen terug, maar ik leer ook bij.",
        "Ik kan dingen opnoemen die wel goed gingen deze week.",
        "Fouten maken hoort bij mens zijn."]),
    ("Ik ga nooit vrienden maken in Leuven.", "fortune_telling", [
        "Vrienden maken in een nieuwe stad vraagt tijd.",
        "Er zijn veel kringen en clubs waar ik mensen kan leren kennen.",
        "Ik kan deze week één activiteit uitproberen."]),
    ("Ik moet alles perfect doen of het telt niet.", "all_or_nothing", [
        "Goed genoeg is vaak echt genoeg.",
        "Perfectie is onhaalbaar, vooruitgang wel.",
        "Ik kan bepalen wat voor deze taak echt belangrijk is."]),
    ("Mijn ouders betalen alles en ik stel hen teleur.", "mind_reading", [
        "Ik weet niet zeker of ze teleurgesteld zijn tenzij ik het vraag.",
        "Ouders steunen hun kind meestal ook als het moeilijk gaat.",
        "Ik kan eerlijk met hen praten over hoe het gaat."]),
    ("Ik heb mijn thesis nog niet gestart, het is te laat.", "catastrophizing", [
        "Het voelt laat, maar er is waarschijnlijk nog tijd als ik nu begin.",
        "Ik kan met mijn promotor een realistische planning maken.",
        "Elke dag dat ik eraan werk, brengt me dichterbij."]),
    ("Mijn presentatie was een ramp omdat ik even stil viel.", "all_or_nothing", [
        "Even stilvallen maakt een presentatie geen ramp.",
        "Het publiek onthoudt vooral de inhoud.",
        "Het grootste deel van mijn presentatie ging prima."]),
    ("Ik ben de enige die het niet snapt.", "overgeneralizing", [
        "Waarschijnlijk zijn er anderen die het ook niet snappen maar niets zeggen.",
        "Het is normaal dat sommige stof tijd nodig heeft.",
        "Ik kan een vraag stellen in de oefensessie."]),
    ("Mijn vriend reageerde kortaf, ik heb vast iets fout gedaan.", "personalization", [
        "Mijn vriend kan om allerlei redenen kortaf zijn.",
        "Eén kort bericht zegt niets over onze vriendschap.",
        "Ik kan gewoon vragen of alles oké is."]),
    ("Ik ben lui omdat ik vandaag niets gedaan heb.", "labeling", [
        "Een dag zonder veel te doen maakt mij niet lui.",
        "Misschien had ik gewoon rust nodig.",
        "Ik kan morgen klein beginnen met één taak."]),
    ("Ik zal nooit een job vinden met dit diploma.", "fortune_telling", [
        "Ik kan de toekomst niet voorspellen.",
        "Veel afgestudeerden vinden werk, ook buiten hun richting.",
        "De loopbaanbegeleiding kan mij helpen opties te zien."]),
    ("Ik voel me schuldig als ik een pauze neem, dus ik doe het vast slecht.", "emotional_reasoning", [
        "Schuldgevoel betekent niet dat ik het slecht doe.",
        "Pauzes helpen me om daarna beter te werken.",
        "Ik kan kijken naar wat ik echt al gedaan heb."]),
    ("Mijn kotgenoot is boos en dat is mijn schuld.", "personalization", [
        "De bui van mijn kotgenoot kan veel oorzaken hebben.",
        "Als ik iets fout deed, kunnen we er rustig over praten.",
        "Ik ben niet verantwoordelijk voor elk gevoel van anderen."]),
    ("Ik ben gezakt voor mijn rijexamen, ik kan niks.", "overgeneralizing", [
        "Eén keer zakken betekent niet dat ik niks kan.",
        "Veel mensen slagen pas de tweede keer.",
        "Ik weet nu beter wat ik moet oefenen."]),
    ("Op sociale media lijkt iedereen gelukkiger dan ik.", "overgeneralizing", [
        "Sociale media tonen vooral de mooie momenten.",
        "Iedereen heeft dingen waar die mee worstelt.",
        "Ik kan kijken naar wat ik zelf al opgebouwd heb."]),
    ("Mijn prof zei dat mijn paper goed was, maar hij is gewoon vriendelijk.", "discounting_positives", [
        "Proffen geven meestal eerlijke feedback over het werk.",
        "Ik mag een compliment aannemen in plaats van het weg te redeneren.",
        "Ik heb hard aan die paper gewerkt, en dat is te zien."]),
    ("Ik moet altijd beschikbaar zijn voor mijn vrienden.", "should_statements", [
        "Ik mag grenzen stellen, ook bij vrienden.",
        "Goede vrienden begrijpen dat ik soms tijd voor mezelf nodig heb.",
        "Voor mezelf zorgen helpt me ook om er voor hen te zijn."]),
    ("Als ik naar de fuif ga, sta ik toch alleen in een hoekje.", "fortune_telling", [
        "Ik weet niet hoe de avond zal lopen.",
        "Ik kan met iemand afspreken om samen te gaan.",
        "Als het niet leuk is, mag ik gewoon vroeger naar huis."]),
    ("Ik heb een herexamen, dus mijn zomer is verpest.", "all_or_nothing", [
        "Een herexamen vraagt tijd, maar mijn hele zomer is niet verpest.",
        "Ik kan studeren en ook leuke dingen plannen.",
        "Na het examen heb ik nog vrije tijd."]),
    ("Ik zou al lang moeten weten wat ik wil worden.", "should_statements", [
        "Veel mensen weten dat pas veel later, en dat is oké.",
        "Uitzoeken wat ik wil is een proces.",
        "Ik kan stap voor stap ontdekken wat me boeit."]),
    ("Mijn groepswerk gaat mislukken en het zal mijn fout zijn.", "fortune_telling", [
        "Ik weet nog niet hoe het groepswerk zal uitdraaien.",
        "Het resultaat hangt van de hele groep af.",
        "Ik kan mijn deel goed doen en de groep laten weten waar ik sta."]),
    ("Ik ben veel te verlegen voor een studentenleven.", "labeling", [
        "Verlegen zijn betekent niet dat ik geen studentenleven kan hebben.",
        "Kleine groepen kunnen voor mij gemakkelijker zijn.",
        "Ik heb geen grote vriendengroep nodig, een paar goede vrienden is genoeg."]),
    ("Ik heb te veel geld uitgegeven deze maand, ik kan niet met geld omgaan.", "labeling", [
        "Eén dure maand betekent niet dat ik niet met geld kan omgaan.",
        "Budgetteren leer je met vallen en opstaan.",
        "Ik kan een eenvoudig budget maken voor volgende maand."]),
    ("Mijn promotor had veel opmerkingen, dus mijn tekst is slecht.", "emotional_reasoning", [
        "Veel feedback betekent vaak dat mijn promotor mijn werk serieus neemt.",
        "Een eerste versie hoort opmerkingen te krijgen.",
        "Ik kan de opmerkingen één voor één verwerken."]),
    ("Ik ben bezorgd of ik mijn huur volgende maand kan betalen.", "none", [
        "Dit is een echte zorg, en het is goed dat ik het nu al zie.",
        "De sociale dienst van de universiteit kan misschien helpen.",
        "Een overzicht van mijn uitgaven toont waar ik sta."]),
    ("Mijn oma is ziek en ik kan me niet concentreren.", "none", [
        "Het is logisch dat ik me niet kan concentreren nu oma ziek is.",
        "Ik kan mijn studietrajectbegeleider inlichten.",
        "Elke dag een beetje doen is nu genoeg."]),
    ("Ik heb drie examens in vier dagen en ik ben uitgeput.", "none", [
        "Dat is echt een zware planning, uitgeput zijn is begrijpelijk.",
        "Slaap helpt mijn geheugen meer dan een extra nachtje doordoen.",
        "Ik kan korte herhalingen plannen met echte pauzes."]),
    ("Ik heb heimwee en het wordt erger.", "none", [
        "Heimwee is heel normaal, zeker de eerste maanden.",
        "Een vast belmoment met thuis kan helpen.",
        "Kleine routines hier kunnen het meer als thuis laten voelen."]),
    ("Ik ken niemand in mijn nieuwe richting.", "none", [
        "Ergens nieuw beginnen zonder iemand te kennen is voor iedereen moeilijk.",
        "Anderen zoeken waarschijnlijk ook aansluiting.",
        "Ik kan in de volgende les iemand aanspreken."]),
    ("ik kan echt niks", "overgeneralizing", [
        "Ik heb het nu moeilijk, maar ik kan wel degelijk dingen.",
        "Ik kan drie dingen bedenken die ik deze week goed deed.",
        "Dit gevoel gaat ook weer voorbij."]),
    ("waarom ben ik altijd zo", "labeling", [
        "Ik ben gefrustreerd op mezelf, en dat is begrijpelijk.",
        "Dit moment zegt niet alles over wie ik ben.",
        "Ik kan me afvragen wat ik nu nodig heb, in plaats van streng te zijn."]),
    ("niemand reageert ooit op mijn berichten", "overgeneralizing", [
        "Sommige berichten blijven onbeantwoord, maar niet allemaal.",
        "Mensen zijn vaak druk en vergeten te antwoorden.",
        "Ik kan één vriend rechtstreeks bellen."]),
    ("Ik heb een fout gemaakt in het labo, iedereen denkt nu dat ik onhandig ben.", "mind_reading", [
        "Iedereen maakt fouten in het labo, zo leer je het.",
        "De anderen zijn vooral met hun eigen proef bezig.",
        "Ik kan de assistent om een tip vragen."]),
    ("Ik ben niet zo slim als mijn broer, ik zal altijd tegenvallen.", "fortune_telling", [
        "Mijn broer en ik hebben elk onze eigen sterktes.",
        "Ik hoef niet zijn pad te volgen om te slagen.",
        "Mijn familie kan trots zijn op verschillende dingen."]),
    ("Ik studeer al weken en ik heb nog steeds het gevoel dat ik niks weet.", "emotional_reasoning", [
        "Het gevoel dat ik niks weet, klopt meestal niet met wat ik echt kan.",
        "Ik kan mezelf testen met oefenvragen om te zien wat ik al ken.",
        "Veel studenten voelen dit vlak voor examens."]),
    ("Mijn lief heeft het uitgemaakt, ik ben niets waard.", "labeling", [
        "Een breuk doet pijn, maar mijn waarde hangt er niet van af.",
        "Ik mag verdrietig zijn en tegelijk weten dat ik waardevol ben.",
        "Ik kan steun zoeken bij vrienden."]),
    ("Ik heb hier nog niemand bij wie ik echt mezelf kan zijn.", "overgeneralizing", [
        "Ik voel me nu eenzaam, maar ik heb wel mensen met wie ik praat.",
        "Echte vriendschappen groeien met tijd.",
        "Ik kan iemand die ik leuk vind voor een koffie uitnodigen."]),
    ("Ik heb mijn studentenjob verprutst, ze gaan me ontslaan.", "catastrophizing", [
        "Eén slechte dag leidt zelden tot ontslag.",
        "Werkgevers weten dat iedereen eens een fout maakt.",
        "Ik kan mijn verantwoordelijke vragen wat ik beter kan doen."]),
    ("Als ik ga praten met de studentenpsycholoog, betekent dat dat ik zwak ben.", "labeling", [
        "Hulp zoeken is een sterke en verstandige keuze.",
        "Veel studenten praten met een psycholoog, dat is heel normaal.",
        "Ik mag steun vragen voordat het te zwaar wordt."]),
    ("Ik ben te oud om nog te studeren, iedereen kijkt raar naar mij.", "mind_reading", [
        "Mensen beginnen op alle leeftijden te studeren.",
        "Mijn levenservaring is eerder een voordeel.",
        "De meeste medestudenten zijn met hun eigen studie bezig."]),
    ("Ik kan geen Nederlands goed, ik zal hier nooit passen.", "fortune_telling", [
        "Een taal leren vraagt tijd, en ik ben al bezig.",
        "Veel mensen helpen graag of schakelen over naar het Engels.",
        "Ik pas ook ergens bij door gedeelde interesses."]),
    ("Ik ben gestopt met sporten, ik heb gewoon geen discipline.", "labeling", [
        "Even stoppen betekent niet dat ik geen discipline heb.",
        "Drukke periodes maken routines moeilijker voor iedereen.",
        "Ik kan opnieuw beginnen met iets kleins, zoals een korte wandeling."]),
    ("Mijn medestudenten hebben allemaal een stage gevonden en ik niet, ik ben waardeloos.", "labeling", [
        "Nog geen stage hebben maakt mij niet waardeloos.",
        "Stages vinden hangt van veel factoren af.",
        "Ik kan mijn cv laten nalezen en blijven solliciteren."]),
    ("Ik moet nog zoveel doen dat ik niet eens weet waar te beginnen, het lukt nooit.", "catastrophizing", [
        "Het voelt overweldigend, maar ik kan het opdelen in kleine stappen.",
        "Ik kan beginnen met de taak met de vroegste deadline.",
        "Eén ding afvinken geeft vaak meteen wat rust."]),
    ("De prof keek boos naar mij tijdens de les, ik heb vast iets fout gedaan.", "personalization", [
        "Een blik zegt weinig; misschien dacht hij aan iets anders.",
        "Ik heb geen bewijs dat ik iets fout deed.",
        "Als het me blijft bezighouden, kan ik het na de les vragen."]),
    ("Ik moet altijd vrolijk zijn, anders vinden mensen mij saai.", "should_statements", [
        "Niemand is altijd vrolijk, en dat verwacht ook niemand.",
        "Eerlijk zijn over een slechte dag kan mensen dichterbij brengen.",
        "Ik mag ups en downs hebben zoals iedereen."]),
    ("Na één slechte nacht weet ik dat het examen morgen slecht gaat.", "fortune_telling", [
        "Eén slechte nacht bepaalt niet hoe het examen gaat.",
        "Adrenaline helpt vaak om wakker te blijven tijdens een examen.",
        "Ik kan vanavond rustig herhalen en vroeg gaan slapen."]),
    ("Ik heb 30 studiepunten niet gehaald, mijn toekomst is voorbij.", "catastrophizing", [
        "Dat is een zware tegenslag, maar mijn toekomst is niet voorbij.",
        "Een studietrajectbegeleider kan samen met mij een plan maken.",
        "Veel mensen vinden hun weg na een moeilijk jaar."]),
    ("Mijn vrienden gaan op reis en ik kan het niet betalen, ze zullen me saai vinden.", "mind_reading", [
        "Echte vrienden begrijpen dat niet iedereen alles kan betalen.",
        "Nee zeggen tegen één reis maakt mij niet saai.",
        "Ik kan een goedkoper plan voorstellen om samen te doen."]),
    ("Iedereen ziet dat ik rood word als ik spreek.", "mind_reading", [
        "Rood worden is vaak minder zichtbaar dan het voelt.",
        "Ook als mensen het zien, denken ze er meestal niet verder over na.",
        "Rood worden is een normale reactie."]),
]
