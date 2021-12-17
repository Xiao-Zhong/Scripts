// import only `hello()` from the "bar" module
import hello from "bar";
var hungry = "hippo";
function awesome() {
    console.log(
        hello( hungry ).toUpperCase()
    );
}
export awesome;
