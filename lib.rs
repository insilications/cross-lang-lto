#[no_mangle]
#[inline(never)]
pub extern "C" fn foo() {
    println!("abc");
}
