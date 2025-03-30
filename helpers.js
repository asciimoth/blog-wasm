const fs = require('fs');
const util = require('node:util');
const exec = util.promisify(require('node:child_process').exec);

const log = console.log;

const tostr = (arr) => {
    return Buffer.from(arr.buffer).toString();
}

const debugPrint = (mem, f, t) => {
    log(tostr(new Uint8Array(mem.buffer).slice(f, t)));
}

function sleepSync(ms) {
    const sharedArray = new Int32Array(new SharedArrayBuffer(4));
    Atomics.wait(sharedArray, 0, 0, ms);
}

const compile = async (file) => {
    const src = file+".wat";
    const dst = file+".wasm";
    const cmd = "wat2wasm "+src+" -o "+dst
    const { error, stdout, stderr } = await exec(cmd);
    if (error) {
        console.log(error.message);
        return null;
    }
    if (stderr) {
        console.log(stderr);
        return null;
    }
    console.log(stdout);
    return dst
}

const load = async (file, imports = {}) => {
    let mod = undefined;
    imports.debugPrint = (f, t) => {
        debugPrint(mod.instance.exports.memory, f, t);
    };
    imports.debugPrintI32 = log;
    imports.debugPrintI64 = log;
    imports.debugPrintF32 = log;
    imports.debugPrintF64 = log;
    imports.debugClear = console.clear;
    imports.debugSleep = sleepSync;
    imports.debugRand = Math.random;
    const compiled = await compile(file);
    mod = await WebAssembly.instantiate(
        fs.readFileSync(compiled), {import: imports}
    );
    return mod.instance.exports
}
