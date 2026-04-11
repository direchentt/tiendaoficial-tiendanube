import { cookies } from "next/headers";
import { COOKIE_NAME, verifySession } from "./admin-session";

/** Rutas API admin: header x-admin-secret o cookie de sesion del panel. */
export async function isAdminRequest(req: Request): Promise<boolean> {
  const secret = process.env.ADMIN_SECRET;
  if (!secret) {
    return false;
  }
  const hdr = req.headers.get("x-admin-secret");
  if (hdr === secret) {
    return true;
  }
  const cookieVal = cookies().get(COOKIE_NAME)?.value;
  return verifySession(secret, cookieVal);
}
