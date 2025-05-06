import React, { useState, useEffect, useCallback } from 'react';
// Importa le funzioni necessarie da Firebase SDK
import { initializeApp } from "firebase/app";
import { 
    getFirestore, 
    collection, 
    addDoc, 
    getDocs, 
    updateDoc, 
    deleteDoc, 
    doc,
    query,
    orderBy,
    where, // Importa 'where' per i filtri
    Timestamp // Per gestire le date
} from "firebase/firestore"; 

// --- ICONE SVG (Invariate, omesse per brevità) ---
const EditIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5 mr-1"><path strokeLinecap="round" strokeLinejoin="round" d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0115.75 21H5.25A2.25 2.25 0 013 18.75V8.25A2.25 2.25 0 015.25 6H10" /></svg>;
const DeleteIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5 mr-1"><path strokeLinecap="round" strokeLinejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12.56 0c1.153 0 2.243.096 3.222.261m3.222.261L12 5.291M12 5.291A2.25 2.25 0 0112.75 3h-1.5A2.25 2.25 0 019.75 5.291M12 5.291L12 3m0 0V1.5M12 1.5H9.75M12 1.5H14.25" /></svg>;
const PlusIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6 mr-2"><path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" /></svg>;
const LinkIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-4 h-4 ml-2 opacity-50"><path strokeLinecap="round" strokeLinejoin="round" d="M13.19 8.688a4.5 4.5 0 011.242 7.244l-4.5 4.5a4.5 4.5 0 01-6.364-6.364l1.757-1.757m13.35-.622l1.757-1.757a4.5 4.5 0 00-6.364-6.364l-4.5 4.5a4.5 4.5 0 001.242 7.244" /></svg>;
const ExternalLinkIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5 mr-2"><path strokeLinecap="round" strokeLinejoin="round" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" /></svg>;
const SparklesIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5 mr-2"><path strokeLinecap="round" strokeLinejoin="round" d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L1.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.25 12L17 13.75M18.25 12L17 10.25M18.25 12L19.5 11.25M18.25 12L19.5 12.75M12 3.75L10.75 5M12 3.75L13.25 5M12 3.75L11.25 2.5M12 3.75L12.75 2.5m0 15L10.75 19M12 20.25L13.25 19M12 20.25L11.25 21.5M12 20.25L12.75 21.5m-5.25-5.25L5 13.75M6.75 15L5 16.25m1.75-1.25L8 15.75M6.75 15L8 14.25m5.25 5.25L13.75 19M15 16.25L16.25 19M15 16.25L15.75 18M15 16.25L14.25 18" /></svg>;
const ShareIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5 mr-1"><path strokeLinecap="round" strokeLinejoin="round" d="M7.217 10.907a2.25 2.25 0 100 2.186m0-2.186c.195.025.39.05.588.05h5.408a2.25 2.25 0 100-2.186m-5.408 2.186L6.637 10.907m0 2.186l.58 1.035M11.25 10.907v2.186m0 0v2.186m0-2.186l-.58-1.035m0 1.035L12 13.093m0-2.186l.58-1.035m0 0L12 8.723m5.25 2.184l-.587-1.035m0 1.035l.588 1.035m0-1.035h.001M12 8.723L12.588 7.69m-1.176 0L12 5.25m0 0L12.588 4.22m-1.176 0L12 2.25" /></svg>;
const CopyLinkIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5"><path strokeLinecap="round" strokeLinejoin="round" d="M15.666 3.888A2.25 2.25 0 0013.5 2.25h-3c-1.03 0-1.9.693-2.166 1.638m7.332 0c.055.194.084.4.084.612v0a2.25 2.25 0 01-2.25 2.25h-1.5a2.25 2.25 0 01-2.25-2.25V4.5m6 0v1.5m-3-1.5V3.75M3.75 6A2.25 2.25 0 016 3.75h1.5V1.5c0-.414.336-.75.75-.75h3c.414 0 .75.336.75.75v2.25h1.5A2.25 2.25 0 0118 6v12a2.25 2.25 0 01-2.25 2.25H6A2.25 2.25 0 013.75 18V6z" /></svg>;
const PhoneIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5 mr-1.5"><path strokeLinecap="round" strokeLinejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 002.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 01-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 00-1.091-.852H4.5A2.25 2.25 0 002.25 4.5v2.25z" /></svg>;
const EmailActionIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-5 h-5 mr-1.5"><path strokeLinecap="round" strokeLinejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75" /></svg>;
const WhatsAppActionIcon = () => <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 24 24" className="w-5 h-5 mr-1.5"><path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946.003-6.556 5.338-11.891 11.893-11.891 3.181.001 6.167 1.24 8.413 3.488 2.245 2.248 3.481 5.236 3.48 8.414-.003 6.557-5.338 11.892-11.893 11.892-1.99-.001-3.951-.5-5.688-1.448L.057 24zm6.597-3.807c1.676.995 3.276 1.591 5.392 1.592 5.448 0 9.886-4.434 9.889-9.885.002-5.462-4.415-9.89-9.881-9.892-5.452 0-9.887 4.434-9.889 9.884-.001 2.225.651 3.891 1.746 5.634l-.999 3.648 3.742-.981zm11.387-5.464c-.074-.124-.272-.198-.57-.347-.297-.149-1.758-.868-2.031-.967-.272-.099-.47-.149-.669.149-.198.297-.768.967-.941 1.165-.173.198-.347.223-.644.074-.297-.149-1.255-.462-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.297-.347.446-.521.151-.172.2-.296.3-.495.099-.198.05-.372-.025-.521-.075-.148-.669-1.611-.916-2.206-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01s-.521.074-.792.372c-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.626.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.695.248-1.289.173-1.413z"/></svg>;
// --- FINE ICONE SVG ---


// --- Configurazione Firebase ---
// SOSTITUISCI QUESTO OGGETTO CON LE TUE CREDENZIALI FIREBASE!
// Le trovi nel pannello del tuo progetto Firebase:
// Impostazioni progetto -> Generali -> Le tue app -> Seleziona app Web -> Configurazione -> Oggetto firebaseConfig
const firebaseConfig = {
  apiKey: "YOUR_API_KEY", // Sostituisci
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com", // Sostituisci
  projectId: "YOUR_PROJECT_ID", // Sostituisci
  storageBucket: "YOUR_PROJECT_ID.appspot.com", // Sostituisci
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID", // Sostituisci
  appId: "YOUR_APP_ID" // Sostituisci
};

// Inizializza Firebase
const app = initializeApp(firebaseConfig);
// Ottieni un riferimento a Firestore
const db = getFirestore(app);
// Riferimento alla collezione 'annunci' in Firestore
const annunciCollectionRef = collection(db, "annunci");
// --- Fine Configurazione Firebase ---


// Componente per un singolo annuncio
function AnnuncioItem({ annuncio, onEdit, onDelete }) {
  const [isExpanded, setIsExpanded] = useState(false);
  const [showShareOptions, setShowShareOptions] = useState(false);
  const [copiedLink, setCopiedLink] = useState(false);

  const hasContent = annuncio.content && annuncio.content.trim() !== '';
  // Converti Firestore Timestamp in Date per la visualizzazione
  const publicationDate = annuncio.date instanceof Timestamp 
    ? annuncio.date.toDate() 
    : new Date(annuncio.date); // Fallback se la data non è un Timestamp

  const contentToShow = annuncio.content || "";
  const isLongContent = hasContent && contentToShow.length > 100;
  
  let displayContentText = contentToShow;
  if (isLongContent && !isExpanded) {
    displayContentText = `${contentToShow.substring(0, 100)}...`;
  }

  const placeholderImage = "https://placehold.co/600x400/E0E0E0/B0B0B0?text=Anteprima+non+disponibile";
  const shareUrl = annuncio.url || window.location.href; 
  const shareTitle = annuncio.title || "Dai un'occhiata a questo annuncio";
  const shareDescription = annuncio.content?.substring(0, 200) || "Interessante annuncio su Affitti Milano";

  const handleContactAdvertiser = () => {
    if (annuncio.url) {
      window.open(annuncio.url, '_blank', 'noopener,noreferrer');
    }
  };

  const handleCopyLink = () => {
    navigator.clipboard.writeText(shareUrl).then(() => {
      setCopiedLink(true);
      setTimeout(() => setCopiedLink(false), 2000); 
    }).catch(err => {
      console.error('Errore nel copiare il link: ', err);
      alert('Impossibile copiare il link. Per favore, fallo manualmente.');
    });
  };

  const socialShareLinks = [
    { name: 'Facebook', url: `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}` },
    { name: 'Twitter', url: `https://twitter.com/intent/tweet?url=${encodeURIComponent(shareUrl)}&text=${encodeURIComponent(shareTitle)}` },
    { name: 'WhatsApp', url: `https://api.whatsapp.com/send?text=${encodeURIComponent(shareTitle + " " + shareUrl)}` },
    { name: 'LinkedIn', url: `https://www.linkedin.com/shareArticle?mini=true&url=${encodeURIComponent(shareUrl)}&title=${encodeURIComponent(shareTitle)}&summary=${encodeURIComponent(shareDescription)}` },
    { name: 'Pinterest', url: `https://pinterest.com/pin/create/button/?url=${encodeURIComponent(shareUrl)}&media=${encodeURIComponent(annuncio.imageUrl || placeholderImage)}&description=${encodeURIComponent(shareTitle)}` },
    { name: 'Reddit', url: `https://www.reddit.com/submit?url=${encodeURIComponent(shareUrl)}&title=${encodeURIComponent(shareTitle)}` },
    { name: 'Telegram', url: `https://t.me/share/url?url=${encodeURIComponent(shareUrl)}&text=${encodeURIComponent(shareTitle)}` },
    { name: 'Email', url: `mailto:?subject=${encodeURIComponent(shareTitle)}&body=${encodeURIComponent("Ho trovato questo annuncio interessante: " + shareUrl)}` },
  ];

  const typeBadgeClass = annuncio.type === 'offro' 
    ? "bg-green-100 text-green-800" 
    : "bg-orange-100 text-orange-800";
  const typeBadgeText = annuncio.type === 'offro' ? "OFFERTA" : "RICHIESTA";


  return (
    <article className="mb-8 p-6 bg-white rounded-lg shadow-lg hover:shadow-xl transition-shadow duration-300 relative">
      {annuncio.type && (
        <span className={`absolute top-4 right-4 text-xs font-semibold px-2.5 py-0.5 rounded-full ${typeBadgeClass}`}>
          {typeBadgeText}
        </span>
      )}
      <img 
        src={annuncio.imageUrl || placeholderImage} 
        alt={`Immagine per ${annuncio.title}`} 
        className="w-full h-48 object-cover rounded-md mb-4 bg-gray-200"
        onError={(e) => { 
            if (e.target.src !== placeholderImage) {
                e.target.src = placeholderImage; 
            }
            e.target.classList.add('opacity-70');
        }}
      />
      <h2 className="text-3xl font-bold mb-2 text-gray-800 pr-24"> 
        {annuncio.url ? (
          <a 
            href={annuncio.url} 
            target="_blank" 
            rel="noopener noreferrer" 
            className="hover:text-blue-600 hover:underline inline-flex items-center"
            title={`Vai all'annuncio originale: ${annuncio.title}`}
          >
            {annuncio.title}
            <LinkIcon />
          </a>
        ) : (
          annuncio.title
        )}
      </h2>
      
      <p className="text-sm text-gray-500 mb-4">Pubblicato il: {publicationDate.toLocaleDateString('it-IT')}</p>
      
      {hasContent && (
        <div 
          className="prose max-w-none text-gray-700 mb-4" 
          dangerouslySetInnerHTML={{ __html: displayContentText.replace(/\n/g, '<br />') }} 
        />
      )}
      {isLongContent && (
        <button
          onClick={() => setIsExpanded(!isExpanded)}
          className="text-blue-600 hover:text-blue-800 font-semibold mb-4 inline-block"
        >
          {isExpanded ? 'Leggi meno' : 'Leggi tutto'}
        </button>
      )}

      {/* Informazioni di Contatto Specifiche */}
      <div className="my-4 space-y-3"> 
        {(annuncio.contactPhone || annuncio.contactEmail || annuncio.contactWhatsapp) && (
            <h4 className="text-md font-semibold text-gray-700 mb-3">Contatta l'inserzionista:</h4>
        )}
        <div className="flex flex-wrap gap-3 items-center"> 
            {annuncio.contactWhatsapp && (
              <a 
                href={`https://wa.me/${annuncio.contactWhatsapp.replace(/\D/g, '')}`} 
                target="_blank" 
                rel="noopener noreferrer" 
                className="inline-flex items-center justify-center px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors duration-200 text-sm font-medium shadow-md hover:shadow-lg"
                title="Contatta su WhatsApp"
              >
                <WhatsAppActionIcon /> WhatsApp
              </a>
            )}
            {annuncio.contactEmail && (
              <a 
                href={`mailto:${annuncio.contactEmail}`} 
                className="inline-flex items-center justify-center px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors duration-200 text-sm font-medium shadow-md hover:shadow-lg"
                title="Invia Email"
              >
                <EmailActionIcon /> Email
              </a>
            )}
             {annuncio.contactPhone && ( 
              <a 
                href={`tel:${annuncio.contactPhone}`} 
                className="inline-flex items-center justify-center px-4 py-2 bg-sky-500 text-white rounded-lg hover:bg-sky-600 transition-colors duration-200 text-sm font-medium shadow-md hover:shadow-lg"
                title={`Chiama ${annuncio.contactPhone}`}
              >
                <PhoneIcon /> Chiama ({annuncio.contactPhone})
              </a>
            )}
        </div>
      </div>


      <div className="mt-6 flex flex-wrap items-center gap-3">
        {annuncio.url && ( 
          <button
            onClick={handleContactAdvertiser}
            className="flex items-center justify-center px-5 py-2.5 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors duration-200 text-sm font-medium shadow-md hover:shadow-lg"
            title="Vai al link originale dell'annuncio"
          >
            <ExternalLinkIcon />
            Link Annuncio
          </button>
        )}
        <button
          onClick={() => onEdit(annuncio)}
          className="flex items-center justify-center px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition-colors duration-200 text-sm font-medium shadow-md hover:shadow-lg"
        >
          <EditIcon /> Modifica
        </button>
        <button
          onClick={() => onDelete(annuncio.id)} // Passa l'ID Firestore
          className="flex items-center justify-center px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors duration-200 text-sm font-medium shadow-md hover:shadow-lg"
        >
          <DeleteIcon /> Elimina
        </button>
        <button
            onClick={() => setShowShareOptions(!showShareOptions)}
            className="flex items-center justify-center px-4 py-2 bg-gray-500 text-white rounded-lg hover:bg-gray-600 transition-colors duration-200 text-sm font-medium shadow-md hover:shadow-lg"
            title="Condividi annuncio"
        >
            <ShareIcon/> Condividi
        </button>
      </div>
      
      {showShareOptions && (
        <div className="mt-4 p-4 bg-gray-50 rounded-lg shadow">
          <p className="text-sm font-semibold text-gray-700 mb-3">Condividi su:</p>
          <div className="flex flex-wrap gap-3 items-center">
            {socialShareLinks.map(platform => (
              <a
                key={platform.name}
                href={platform.url}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center justify-center px-3 py-2 text-sm bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-md transition-colors"
                title={`Condividi su ${platform.name}`}
              >
                {platform.name} 
              </a>
            ))}
            <button
              onClick={handleCopyLink}
              className="inline-flex items-center justify-center px-3 py-2 text-sm bg-gray-200 hover:bg-gray-300 text-gray-700 rounded-md transition-colors"
              title="Copia link"
            >
              <CopyLinkIcon />
              <span className="ml-1.5">{copiedLink ? 'Copiato!' : 'Copia Link'}</span>
            </button>
          </div>
        </div>
      )}
    </article>
  );
}

// Componente per il modulo di aggiunta/modifica annuncio
function AnnuncioForm({ onSubmit, initialData, onCancel }) {
  const [title, setTitle] = useState('');
  const [url, setUrl] = useState(''); 
  const [content, setContent] = useState('');
  const [manualImageUrl, setManualImageUrl] = useState(''); 
  const [annuncioType, setAnnuncioType] = useState('offro'); 
  const [contactPhone, setContactPhone] = useState('');
  const [contactEmail, setContactEmail] = useState('');
  const [contactWhatsapp, setContactWhatsapp] = useState('');

  const [isFetchingMetadata, setIsFetchingMetadata] = useState(false);
  const [fetchError, setFetchError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false); // Stato per indicare l'invio

  const isEditing = !!initialData;

  useEffect(() => {
    if (initialData) {
      setTitle(initialData.title || '');
      setUrl(initialData.url || '');
      setContent(initialData.content || '');
      setManualImageUrl(initialData.imageUrl || ''); 
      setAnnuncioType(initialData.type || 'offro');
      setContactPhone(initialData.contactPhone || '');
      setContactEmail(initialData.contactEmail || '');
      setContactWhatsapp(initialData.contactWhatsapp || '');
    } else {
      setTitle('');
      setUrl('');
      setContent('');
      setManualImageUrl('');
      setAnnuncioType('offro'); 
      setContactPhone('');
      setContactEmail('');
      setContactWhatsapp('');
    }
    setFetchError('');
  }, [initialData]);

  const isValidHttpUrl = (urlString) => {
    if (!urlString) return true; // URL opzionale è valido se vuoto
    let urlObj;
    try {
      urlObj = new URL(urlString);
    } catch (_) {
      return false; 
    }
    return urlObj.protocol === "http:" || urlObj.protocol === "https:";
  };
  
  const isValidEmail = (email) => {
     if (!email) return true; // Email opzionale è valida se vuota
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  };


  const handleMainUrlChange = (e) => {
    const newUrl = e.target.value;
    setUrl(newUrl);
    setFetchError('');
    if (!newUrl.trim()) {
        // Non resettare automaticamente i campi se l'URL viene cancellato
        // L'utente potrebbe voler rimuovere solo l'URL ma mantenere il resto
    }
  };

  const handleFetchMetadata = async () => {
     if (!url.trim() || !isValidHttpUrl(url)) { 
      setFetchError("Per estrarre, inserisci un URL valido nel campo 'Link URL Annuncio'.");
      setIsFetchingMetadata(false); 
      return;
    }
    setFetchError('');
    setIsFetchingMetadata(true);
    // Non resettare qui, l'utente potrebbe aver già compilato qualcosa
    // setTitle(''); 
    // setContent('');
    // setManualImageUrl('');

    const proxyUrl = `https://api.allorigins.win/raw?url=${encodeURIComponent(url)}`;
    try {
      const response = await fetch(proxyUrl);
      if (!response.ok) {
        throw new Error(`Errore HTTP: ${response.status}.`);
      }
      const htmlText = await response.text();
      const parser = new DOMParser();
      const doc = parser.parseFromString(htmlText, 'text/html');
      
      const pageTitle = doc.querySelector('title')?.innerText.trim() || 
                        doc.querySelector('meta[property="og:title"]')?.getAttribute('content')?.trim() ||
                        doc.querySelector('meta[name="twitter:title"]')?.getAttribute('content')?.trim();
      // Popola solo se il campo è vuoto o se l'utente non ha modificato il titolo estratto in precedenza
      if (pageTitle && !title) setTitle(pageTitle); 

      const metaDescription = doc.querySelector('meta[property="og:description"]')?.getAttribute('content')?.trim() ||
                              doc.querySelector('meta[name="description"]')?.getAttribute('content')?.trim() ||
                              doc.querySelector('meta[name="twitter:description"]')?.getAttribute('content')?.trim();
      if (metaDescription && !content) setContent(metaDescription);

      let extractedImageUrl = doc.querySelector('meta[property="og:image"]')?.getAttribute('content')?.trim() ||
                              doc.querySelector('meta[name="twitter:image"]')?.getAttribute('content')?.trim();
      if (extractedImageUrl && !manualImageUrl) { // Popola solo se l'URL immagine manuale è vuoto
        try {
            const absoluteUrl = new URL(extractedImageUrl, url); 
            setManualImageUrl(absoluteUrl.href);
        } catch (e) {
            console.warn("URL immagine estratto non valido:", extractedImageUrl);
        }
      }
    } catch (error) {
      console.error("Errore estrazione metadati:", error);
      setFetchError(`Impossibile estrarre i dati (${error.message}). Puoi compilare i campi manualmente.`);
    } finally {
      setIsFetchingMetadata(false);
    }
  };

  const handleSubmit = async (e) => { // Trasformato in async
    e.preventDefault();
    if (!title.trim()) { 
      alert("Il Titolo Annuncio non può essere vuoto.");
      return;
    }
    if (url.trim() && !isValidHttpUrl(url)) {
        alert("Il Link URL Annuncio fornito non è un URL valido (es. https://www.esempio.com)");
        return;
    }
    if (manualImageUrl.trim() && !isValidHttpUrl(manualImageUrl)) {
        alert("L'URL Immagine fornito non è un URL valido (es. https://www.esempio.com/immagine.jpg)");
        return;
    }
    if (contactEmail.trim() && !isValidEmail(contactEmail)) {
        alert("L'indirizzo email fornito non sembra valido.");
        return;
    }
    
    setIsSubmitting(true); // Inizia l'invio

    const annuncioData = { 
        title, 
        url: url.trim(), 
        content, 
        imageUrl: manualImageUrl, 
        type: annuncioType,
        contactPhone: contactPhone.trim(),
        contactEmail: contactEmail.trim(),
        contactWhatsapp: contactWhatsapp.trim(),
        // Aggiungi la data di creazione/modifica qui usando Firestore Timestamp
        date: Timestamp.now() 
    };

    try {
      await onSubmit(annuncioData); // Chiama la funzione passata da App (che ora gestisce Firestore)
      
      // Resetta il form solo se non è in modalità modifica
      if (!isEditing) { 
          setTitle('');
          setUrl('');
          setContent('');
          setManualImageUrl('');
          setAnnuncioType('offro'); 
          setContactPhone('');
          setContactEmail('');
          setContactWhatsapp('');
      }
      setFetchError('');
    } catch (error) {
        console.error("Errore durante il salvataggio dell'annuncio:", error);
        alert(`Errore nel salvataggio: ${error.message}`);
    } finally {
        setIsSubmitting(false); // Fine invio
    }
  };

  return (
    <form onSubmit={handleSubmit} className="mb-12 p-6 bg-white rounded-lg shadow-md">
      <h2 className="text-2xl font-semibold mb-6 text-gray-700">{isEditing ? 'Modifica Annuncio' : 'Aggiungi Nuovo Annuncio'}</h2>
      
      <div className="mb-6">
        <p className="block text-gray-700 text-sm font-bold mb-2">Tipo di Annuncio:</p>
        <div className="flex items-center space-x-6">
          <label className="flex items-center space-x-2 cursor-pointer">
            <input 
              type="radio" 
              name="annuncioType" 
              value="offro" 
              checked={annuncioType === 'offro'} 
              onChange={(e) => setAnnuncioType(e.target.value)}
              className="form-radio h-5 w-5 text-blue-600"
              disabled={isSubmitting}
            />
            <span className="text-gray-700">Offro Casa</span>
          </label>
          <label className="flex items-center space-x-2 cursor-pointer">
            <input 
              type="radio" 
              name="annuncioType" 
              value="cerco" 
              checked={annuncioType === 'cerco'} 
              onChange={(e) => setAnnuncioType(e.target.value)}
              className="form-radio h-5 w-5 text-orange-600"
              disabled={isSubmitting}
            />
            <span className="text-gray-700">Cerco Casa</span>
          </label>
        </div>
      </div>
      
      <div className="mb-6">
        <label htmlFor="mainUrl" className="block text-gray-700 text-sm font-bold mb-2">
          Link URL Annuncio Esterno (Opzionale):
        </label>
        <div className="flex items-center space-x-2">
            <input
              type="url"
              id="mainUrl"
              value={url}
              onChange={handleMainUrlChange}
              className="shadow appearance-none border rounded-md w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
              placeholder="https://www.sito-annunci.it/id-annuncio (per estrarre info)"
              disabled={isSubmitting}
            />
            <button
                type="button"
                onClick={handleFetchMetadata}
                disabled={isFetchingMetadata || !url.trim() || !isValidHttpUrl(url) || isSubmitting}
                className="flex items-center justify-center px-4 py-3 bg-indigo-500 text-white rounded-md hover:bg-indigo-600 transition-colors duration-200 text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                title="Estrai titolo, descrizione e immagine dall'URL"
            >
                <SparklesIcon />
                {isFetchingMetadata ? 'Caricamento...' : 'Estrai Info'}
            </button>
        </div>
        {fetchError && <p className="text-red-500 text-xs mt-2">{fetchError}</p>}
      </div>

      <div className="mb-6">
        <label htmlFor="title" className="block text-gray-700 text-sm font-bold mb-2">
          Titolo Annuncio (Obbligatorio):
        </label>
        <input
          type="text"
          id="title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="shadow appearance-none border rounded-md w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
          placeholder="Es. Bilocale luminoso zona Navigli"
          required
          disabled={isSubmitting}
        />
      </div>
      
      <div className="mb-6">
        <label htmlFor="manualImageUrl" className="block text-gray-700 text-sm font-bold mb-2">
          URL Immagine (Opzionale):
        </label>
        <input
          type="url"
          id="manualImageUrl"
          value={manualImageUrl}
          onChange={(e) => setManualImageUrl(e.target.value)}
          className="shadow appearance-none border rounded-md w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
          placeholder="https://www.esempio.com/immagine.jpg"
          disabled={isSubmitting}
        />
        {manualImageUrl && isValidHttpUrl(manualImageUrl) && !isFetchingMetadata && ( 
            <div className="mt-4">
                <p className="text-sm text-gray-600 mb-1">Anteprima Immagine:</p>
                <img src={manualImageUrl} alt="Anteprima immagine fornita" className="max-w-xs max-h-32 border rounded"/>
            </div>
        )}
      </div>

      {/* Campi di Contatto */}
      <fieldset className="mb-6 border p-4 rounded-md" disabled={isSubmitting}>
        <legend className="text-gray-700 text-sm font-bold mb-2 px-1">Modalità di Contatto (Opzionale)</legend>
        <div className="space-y-4">
            <div>
                <label htmlFor="contactWhatsapp" className="block text-gray-700 text-xs font-medium mb-1">
                    WhatsApp (es. 393331234567):
                </label>
                <input
                  type="tel"
                  id="contactWhatsapp"
                  value={contactWhatsapp}
                  onChange={(e) => setContactWhatsapp(e.target.value)}
                  className="shadow-sm appearance-none border rounded-md w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-1 focus:ring-blue-500 disabled:bg-gray-100"
                  placeholder="Numero WhatsApp"
                  disabled={isSubmitting}
                />
            </div>
            <div>
                <label htmlFor="contactEmail" className="block text-gray-700 text-xs font-medium mb-1">
                    Email:
                </label>
                <input
                  type="email"
                  id="contactEmail"
                  value={contactEmail}
                  onChange={(e) => setContactEmail(e.target.value)}
                  className="shadow-sm appearance-none border rounded-md w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-1 focus:ring-blue-500 disabled:bg-gray-100"
                  placeholder="indirizzo@esempio.com"
                  disabled={isSubmitting}
                />
            </div>
            <div>
                <label htmlFor="contactPhone" className="block text-gray-700 text-xs font-medium mb-1">
                    Telefono:
                </label>
                <input
                  type="tel"
                  id="contactPhone"
                  value={contactPhone}
                  onChange={(e) => setContactPhone(e.target.value)}
                  className="shadow-sm appearance-none border rounded-md w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-1 focus:ring-blue-500 disabled:bg-gray-100"
                  placeholder="Numero di telefono"
                  disabled={isSubmitting}
                />
            </div>
        </div>
      </fieldset>


      <div className="mb-6">
        <label htmlFor="content" className="block text-gray-700 text-sm font-bold mb-2">
          Descrizione / Dettagli (Opzionale):
        </label>
        <textarea
          id="content"
          value={content}
          onChange={(e) => setContent(e.target.value)}
          rows="6"
          className="shadow appearance-none border rounded-md w-full py-3 px-4 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100"
          placeholder="Aggiungi una descrizione, metri quadri, prezzo, caratteristiche..."
          disabled={isSubmitting}
        />
      </div>
      <div className="flex items-center space-x-4">
        <button
          type="submit"
          className="flex items-center justify-center bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-md focus:outline-none focus:shadow-outline transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          disabled={isSubmitting}
        >
          <PlusIcon /> 
          {isSubmitting ? (isEditing ? 'Salvataggio...' : 'Pubblicazione...') : (isEditing ? 'Salva Modifiche' : 'Pubblica Annuncio')}
        </button>
        {isEditing && (
            <button
                type="button"
                onClick={() => { onCancel(); setFetchError(''); }}
                className="bg-gray-500 hover:bg-gray-600 text-white font-bold py-3 px-6 rounded-md focus:outline-none focus:shadow-outline transition-colors duration-200 disabled:opacity-50"
                disabled={isSubmitting}
            >
                Annulla
            </button>
        )}
      </div>
    </form>
  );
}

// Componente principale dell'App
export default function App() {
  const [annunci, setAnnunci] = useState([]); // Stato inizializzato vuoto, verrà popolato da Firestore
  const [editingAnnuncio, setEditingAnnuncio] = useState(null); 
  const [showForm, setShowForm] = useState(false); 
  const [currentFilter, setCurrentFilter] = useState('all'); 
  const [isLoading, setIsLoading] = useState(true); // Stato per il caricamento iniziale
  const [error, setError] = useState(null); // Stato per errori di fetch

  // Funzione per caricare gli annunci da Firestore
  const fetchAnnunci = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
        let q; // Query Firestore
        // Costruisci la query base ordinando per data decrescente
        const baseQuery = query(annunciCollectionRef, orderBy("date", "desc")); 

        // Aggiungi il filtro se non è 'all'
        if (currentFilter !== 'all') {
            q = query(baseQuery, where("type", "==", currentFilter));
        } else {
            q = baseQuery; // Nessun filtro aggiuntivo
        }

        const querySnapshot = await getDocs(q);
        const annunciData = querySnapshot.docs.map(doc => ({
            ...doc.data(),
            id: doc.id // Aggiunge l'ID del documento Firestore all'oggetto
        }));
        setAnnunci(annunciData);
    } catch (err) {
        console.error("Errore nel caricare gli annunci: ", err);
        setError("Impossibile caricare gli annunci. Riprova più tardi.");
    } finally {
        setIsLoading(false);
    }
  }, [currentFilter]); // Ricarica quando cambia il filtro

  // Carica annunci al mount iniziale e quando cambia il filtro
  useEffect(() => {
    fetchAnnunci();
  }, [fetchAnnunci]); // fetchAnnunci è ora una dipendenza stabile grazie a useCallback

  // Funzione per aggiungere o aggiornare un annuncio su Firestore
  const handleAddOrUpdateAnnuncio = async (annuncioData) => {
    // Rimuovi l'ID se presente, Firestore lo gestisce automaticamente
    const { id, ...dataToSave } = annuncioData; 

    if (editingAnnuncio) {
      // Aggiorna documento esistente
      const annuncioDocRef = doc(db, "annunci", editingAnnuncio.id);
      await updateDoc(annuncioDocRef, dataToSave);
      setEditingAnnuncio(null);
    } else {
      // Aggiungi nuovo documento
      await addDoc(annunciCollectionRef, dataToSave);
    }
    setShowForm(false); 
    fetchAnnunci(); // Ricarica la lista dopo aggiunta/modifica
  };

  const handleEditAnnuncio = (annuncioToEdit) => {
    setEditingAnnuncio(annuncioToEdit);
    setShowForm(true); 
  };

  // Funzione per eliminare un annuncio da Firestore
  const handleDeleteAnnuncio = async (id) => {
    if (window.confirm("Sei sicuro di voler eliminare questo annuncio?")) {
      try {
        const annuncioDocRef = doc(db, "annunci", id);
        await deleteDoc(annuncioDocRef);
        
        // Rimuovi l'annuncio dallo stato locale (opzionale, fetchAnnunci lo farà comunque)
        // setAnnunci(prev => prev.filter(ann => ann.id !== id));

        if (editingAnnuncio && editingAnnuncio.id === id) {
          setEditingAnnuncio(null); 
          setShowForm(false);
        }
        fetchAnnunci(); // Ricarica la lista dopo eliminazione
      } catch (err) {
          console.error("Errore nell'eliminare l'annuncio: ", err);
          alert(`Errore nell'eliminazione: ${err.message}`);
      }
    }
  };

  const handleCancelEdit = () => {
    setEditingAnnuncio(null);
    setShowForm(false);
  };

  const getFilterButtonClass = (filterType) => {
    return currentFilter === filterType 
      ? "bg-blue-600 text-white" 
      : "bg-white text-blue-600 hover:bg-blue-50";
  };

  return (
    <div className="bg-gradient-to-br from-slate-100 to-sky-100 min-h-screen font-sans">
      <div className="container mx-auto px-4 py-12">
        <header className="text-center mb-12">
          <h1 className="text-6xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-blue-600 via-sky-500 to-cyan-400 pb-2">
            AFFITTI MILANO
          </h1>
          <p className="text-xl text-gray-600 mt-2">Trova e pubblica annunci di affitti a Milano</p>
        </header>

        <div className="mb-10 flex justify-center space-x-3 sm:space-x-4">
          <button 
            onClick={() => setCurrentFilter('all')}
            className={`px-4 py-2 sm:px-6 sm:py-2.5 rounded-lg shadow-md font-medium text-sm sm:text-base transition-colors duration-200 ${getFilterButtonClass('all')}`}
          >
            Tutti gli Annunci
          </button>
          <button 
            onClick={() => setCurrentFilter('offro')}
            className={`px-4 py-2 sm:px-6 sm:py-2.5 rounded-lg shadow-md font-medium text-sm sm:text-base transition-colors duration-200 ${getFilterButtonClass('offro')}`}
          >
            Offro Casa
          </button>
          <button 
            onClick={() => setCurrentFilter('cerco')}
            className={`px-4 py-2 sm:px-6 sm:py-2.5 rounded-lg shadow-md font-medium text-sm sm:text-base transition-colors duration-200 ${getFilterButtonClass('cerco')}`}
          >
            Cerco Casa
          </button>
        </div>

        {!showForm && (
          <div className="text-center mb-12">
            <button
              onClick={() => { setEditingAnnuncio(null); setShowForm(true); }}
              className="inline-flex items-center justify-center bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-8 rounded-lg shadow-md hover:shadow-lg transition-all duration-300 transform hover:scale-105 text-lg"
            >
              <PlusIcon /> Inserisci Nuovo Annuncio
            </button>
          </div>
        )}

        {showForm && (
          <AnnuncioForm
            // Passa la funzione che interagisce con Firestore
            onSubmit={handleAddOrUpdateAnnuncio} 
            initialData={editingAnnuncio}
            onCancel={handleCancelEdit}
          />
        )}

        <main>
          {isLoading && (
             <p className="text-center text-gray-600 text-xl mt-8">Caricamento annunci...</p>
          )}
          {error && (
             <p className="text-center text-red-600 text-xl mt-8">{error}</p>
          )}
          {!isLoading && !error && annunci.length === 0 && !showForm && (
            <p className="text-center text-gray-600 text-xl mt-8">
              Nessun annuncio presente {currentFilter !== 'all' ? 'per questo filtro.' : 'ancora. Inizia inserendone uno!'}
            </p>
          )}
          {!isLoading && !error && annunci.length > 0 && annunci.map((ann) => (
            <AnnuncioItem
              key={ann.id} // Usa l'ID di Firestore come chiave
              annuncio={ann}
              onEdit={handleEditAnnuncio}
              onDelete={handleDeleteAnnuncio} // Passa la funzione per eliminare da Firestore
            />
          ))}
        </main>

        <footer className="text-center mt-20 py-8 border-t border-gray-300">
          <p className="text-gray-600">&copy; {new Date().getFullYear()} Affitti Milano. Powered by React & Firebase.</p>
        </footer>
      </div>
    </div>
  );
}
