import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;
import std.stdio;
import std.file;
import std.string;
import std.regex;
import djinja;
import std.datetime.systime : SysTime, Clock;

/** Structure for the documents */
struct Document {
    /** Text of the document */
    string content;
}

/** API interface for documents */
@path("/api/documents/")
interface DocumentAPII
{
    @path("/privacyPolicy")
    Document getPrivacyPolicy(bool website, bool mobileApp, int entityType, string businessName,
    string businessLocation, string websiteUrl, string websiteName, string mobileAppName, bool collectEmail,
    bool collectFirstAndLastName, bool collectPhoneNumber, bool collectAddress, bool askForUserLocation,
    bool useAnalytics, bool canContactByEmail, bool canContactByPhone, bool canContactByWebsite,string contactEmail,
    string contactPhone, string contactWebsite);
}

/** API for documents */
class DocumentAPI : DocumentAPII {
    @trusted
    Document getPrivacyPolicy(bool website, bool mobileApp, int entityType, string businessName,
    string businessLocation, string websiteUrl, string websiteName, string mobileAppName, bool collectEmail,
    bool collectFirstAndLastName, bool collectPhoneNumber,
    bool collectAddress, bool askForUserLocation, bool useAnalytics, bool canContactByEmail, bool canContactByPhone,
    bool canContactByWebsite, string contactEmail, string contactPhone, string contactWebsite) {
        string document = readTextFile("public/privacy-policy-template.html");
        auto todayDate = Clock.currTime;
        string today = format("%s.%d, %s", todayDate.day, todayDate.month, todayDate.year);
        document = renderData!(today, website, mobileApp, entityType, businessName, businessLocation, websiteUrl,
        websiteName, mobileAppName, collectEmail, collectFirstAndLastName, collectPhoneNumber, collectAddress,
        askForUserLocation, useAnalytics, canContactByEmail, canContactByPhone, canContactByWebsite, contactEmail,
        contactPhone, contactWebsite)(document);
        return Document(document);
    }
}

/** Types of documents */
enum DocumentTypes {
    PRIVACY_POLICY = 0
}

/** Function for reading the content of a text file */
string readTextFile(string filename){
	string content = cast(string) std.file.read(filename);
    return content;
}

void main()
{
    auto router = new URLRouter;
	router.registerRestInterface(new DocumentAPI);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, router);

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}